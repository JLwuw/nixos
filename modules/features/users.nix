{
  config,
  pkgs,
  ...
}:
let
  nwDetails = import ../../values/network-details.nix;
in
{
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."users/root".path;
    openssh.authorizedKeys.keys = with nwDetails; [
      laptop.ssh.pubkey
    ];
  };

  users.users.user = {
    home = "/home/user";
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."users/user".path;
    openssh.authorizedKeys.keys =
      with nwDetails;
      map (key: "command=\"${sshShellOverride}\" ${key}") [
        laptop.ssh.pubkey
      ];
  };
}
