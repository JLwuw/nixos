{ config, lib, ... }:
let
  isWorkstation = builtins.elem config.networking.hostName [ "desktop" "laptop" ];

  # Map hostname to secrets file location
  secretsFile = {
    laptop = ../../hosts/laptop/secrets/secrets.yaml;
  }.${config.networking.hostName};
in {
  sops = {
    defaultSopsFormat = "yaml";
    defaultSopsFile = secretsFile;
    age.keyFile = "/persist/var/keys/sops-nix";
    # @source: https://github.com/Mic92/sops-nix/issues/427
    gnupg.sshKeyPaths = [ ];
    # @source: https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
    secrets = {
      "users/root".neededForUsers = true;
      "users/user".neededForUsers = true;
    };
  };
}
