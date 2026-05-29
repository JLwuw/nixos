{
  config,
  lib,
  ...
}:
let
  isServer = config.networking.hostName == "server";
  deviceIds = {
    server = "TKAWGMQ-VGBVXHA-UBVGZTN-MMU5SS3-SYC6WUJ-EHNBO6S-D7IQPBM-WIAWSQY";
    desktop = "RXNQQE7-AH6JL7Z-BIHBKFA-FKGHYZB-Q3MU4TT-S2OYQGU-63PPOUK-R7MFKQ2";
    laptop = "SHBEHJQ-IMMUFWG-TZBFYGJ-RN3X4YT-MIPHIS4-Q6HOEVG-IVPFEMJ-3SHBUAO";
    # Pixel 7 — fill in after first boot: open Syncthing-Fork app → device ID
    # phone = "XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX";
  };
  # Hub-spoke topology
  # server syncs with all clients
  # clients only sync with server
  peers =
    if isServer then
      [
        "desktop"
        "laptop"
        # "phone"
      ]
    else
      [ "server" ];

  # Generic folder generator definition
  mkFolder = name: path: {
    inherit path;
    id = name;
    label = name;
    devices = peers;
    type = "sendreceive";
  };

  # Home folder generator definition
  # Server stores in ~/Sync/, clients as-is home paths
  mkHomeFolder = name: path: {
    path = if isServer then "/home/user/Sync/${name}" else path;
    id = name;
    label = name;
    devices = peers;
    type = "sendreceive";
  };
in
{
  # SOPS secrets for Syncthing identity and authentication
  sops.secrets."syncthing/key.pem" = {
    owner = "user";
    restartUnits = [ "syncthing.service" ];
  };
  sops.secrets."syncthing/cert.pem" = {
    owner = "user";
    restartUnits = [ "syncthing.service" ];
  };
  sops.secrets."syncthing/gui-password" = {
    owner = "user";
    restartUnits = [ "syncthing.service" ];
  };

  # Allow user to read ACME wildcard certs for GUI TLS
  users.users.user.extraGroups = lib.mkIf isServer [ "traefik" ];

  # Symlink ACME certs into Syncthing config dir for GUI HTTPS
  systemd.services.syncthing = lib.mkIf isServer {
    preStart = lib.mkAfter ''
      ln -sf /var/lib/acme/yhkze.net/cert.pem /home/user/.config/syncthing/https-cert.pem
      ln -sf /var/lib/acme/yhkze.net/key.pem /home/user/.config/syncthing/https-key.pem
    '';
  };

  # Syncthing service
  services.syncthing = {
    enable = true;
    user = "user";
    group = "users";
    dataDir = "/home/user";
    configDir = "/home/user/.config/syncthing";

    # Device identity
    key = config.sops.secrets."syncthing/key.pem".path;
    cert = config.sops.secrets."syncthing/cert.pem".path;

    # GUI configuration
    # Server: bind to all interfaces for remote access
    # Clients: localhost only
    guiAddress = "0.0.0.0:8384";
    guiPasswordFile = config.sops.secrets."syncthing/gui-password".path;

    overrideFolders = true; # remove any folders added via the Web GUI that aren't defined declaratively
    overrideDevices = true; # remove any device added via the Web GUI that aren't defined declaratively

    settings = {
      gui.user = "user";
      options = {
        urAccepted = -1; # disable anonymous usage reporting
        startBrowser = false; # don't auto-open browser
      };

      devices = builtins.listToAttrs (
        map (d: {
          name = d;
          value.id = deviceIds.${d};
        }) peers
      );

      folders = {
        atlas = mkFolder "Atlas" "/mnt/atlas";
        documents = mkHomeFolder "Documents" "/home/user/Documents";
        pictures = mkHomeFolder "Pictures" "/home/user/Pictures";
        videos = mkHomeFolder "Videos" "/home/user/Videos";
        software = mkHomeFolder "Software" "/home/user/Software";
        claude = mkHomeFolder "Claude" "/home/user/.claude";
        core = (mkFolder "Core" "/persist/home/user") // {
          ignorePatterns = [
            "!/nixos"
            "!/nixos-*"
            "!/dotfiles"
            "!/nvim"
            "!/competitest.nvim"
            "*"
          ];
        };
        productivity = (mkFolder "Productivity" "/persist/home/user/.config") // {
          ignorePatterns = [
            "!/mochi"
            "*"
          ];
        };
      };
    };
  };

  # Persist Syncthing state
  environment.persistence."/persist".directories = [
    {
      directory = "/home/user/.config/syncthing";
      user = "user";
      group = "users";
    }
  ];

  # Local DNS for Syncthing GUI TLS (wildcard cert requires matching domain)
  networking.hosts = {
    "10.100.0.1" = [ "sync.yhkze.net" ];
    "10.100.0.2" = [ "sync-desktop.yhkze.net" ];
    "10.100.0.3" = [ "sync-laptop.yhkze.net" ];
  };

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [ 22000 ] ++ lib.optionals isServer [ 8384 ]; # Syncthing transfer + GUI (server only)
    allowedUDPPorts = [
      22000 # Syncthing transfer
      21027 # Syncthing discovery
    ];
  };
}
