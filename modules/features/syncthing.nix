{ config, lib, ... }:
let
  deviceIds = {
    laptop = "SHBEHJQ-IMMUFWG-TZBFYGJ-RN3X4YT-MIPHIS4-Q6HOEVG-IVPFEMJ-3SHBUAO";
    # Fill in Windows device ID from Syncthing UI
    windows = "REPLACE_WITH_WINDOWS_DEVICE_ID";
  };
  # Point-to-point: laptop syncs with Windows machine
  devices = [ "windows" ];
in
{
  sops.secrets."syncthing/key.pem" = {
    owner = "user";
    restartUnits = [ "syncthing.service" ];
  };
  sops.secrets."syncthing/cert.pem" = {
    owner = "user";
    restartUnits = [ "syncthing.service" ];
  };

  services.syncthing = {
    enable = true;
    user = "user";
    group = "users";
    dataDir = "/home/user";
    configDir = "/home/user/.config/syncthing";

    key = config.sops.secrets."syncthing/key.pem".path;
    cert = config.sops.secrets."syncthing/cert.pem".path;

    guiAddress = "127.0.0.1:8384";

    overrideFolders = true;
    overrideDevices = true;

    settings = {
      gui.user = "user";
      options = {
        urAccepted = -1;
        startBrowser = false;
      };

      devices = builtins.listToAttrs (
        map (d: {
          name = d;
          value.id = deviceIds.${d};
        }) devices
      );

      folders = {
        documents = {
          path = "/home/user/Documents";
          id = "documents";
          label = "Documents";
          devices = devices;
          type = "sendreceive";
        };
        pictures = {
          path = "/home/user/Pictures";
          id = "pictures";
          label = "Pictures";
          devices = devices;
          type = "sendreceive";
        };
        videos = {
          path = "/home/user/Videos";
          id = "videos";
          label = "Videos";
          devices = devices;
          type = "sendreceive";
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };
}
