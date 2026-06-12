{
  config,
  lib,
  pkgs,
  ...
}:
let
  secretsFile = ./../../hosts/laptop/secrets/secrets.yaml;
in
{
  environment.systemPackages = [ pkgs.sops ];

  sops = {
    defaultSopsFormat = "yaml";
    defaultSopsFile = secretsFile;
    age.keyFile = "/var/keys/sops-nix";
    # @source: https://github.com/Mic92/sops-nix/issues/427
    gnupg.sshKeyPaths = [ ];
    # @source: https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
    secrets = {
      "users/root".neededForUsers = true;
      "users/user".neededForUsers = true;
    };
  };
}
