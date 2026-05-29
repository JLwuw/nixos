# `pkgs`, `lib`, `config` are automatically injected in all modules
# @source: https://nixos.org/manual/nixos/stable/options
{ modulesPath, ... }:
{
  imports = [
    # Enables non-free firmware
    (modulesPath + "/installer/scan/not-detected.nix")
    # Common configuration for QEMU VMs
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ../../../modules/features
    ./packages.nix
  ];

  system.stateVersion = "25.11";
  # Set hostname (required for feature modules to work)
  networking.hostName = "laptop";

  # Home-manager user setup (feature modules provide actual config)
  home-manager = {
    # Store HM and system packages in the same profile
    # useUserPackages = true; # disabled - messes theming up
    # Inherit nixpkgs configuration from system
    useGlobalPkgs = true;
    users.user = {
      home.username = "user";
      home.homeDirectory = "/home/user";
      home.stateVersion = "25.11";
    };
  };
}
