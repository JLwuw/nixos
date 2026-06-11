{
  config,
  pkgs,
  ...
}:
let
  nwDetails = import ../../values/network-details.nix;
  # Forces SSH to use bash for non-interactive commands and nushell for interactive
  # sessions, regardless of the login shell. Works via authorized_keys command= prefix
  # which sets $SSH_ORIGINAL_COMMAND for non-interactive invocations.
  # @source: https://serverfault.com/questions/162018/force-ssh-to-use-a-specific-shell
  sshShellOverride = pkgs.writeShellScript "ssh-shell-override" ''
    if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
      exec ${pkgs.bash}/bin/bash -c "$SSH_ORIGINAL_COMMAND"
    else
      exec ${pkgs.nushell}/bin/nu
    fi
  '';
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
    openssh.authorizedKeys.keys = with nwDetails; map (key: "command=\"${sshShellOverride}\" ${key}") [
      laptop.ssh.pubkey
    ];
  };
}
