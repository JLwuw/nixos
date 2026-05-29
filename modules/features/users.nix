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
  };
  users.users.user = {
    home = "/home/user";
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."users/user".path;
    openssh.authorizedKeys.keys = with nwDetails; [
      server.ssh.pubkey
      desktop.ssh.pubkey
      laptop.ssh.pubkey
    ];
  };
}
