{ pkgs, ... }:
let
  pkgBundle = import ../../../values/package-bundle.nix { inherit pkgs; };
in
{
  # ===========================================================================
  # System packages (environment.systemPackages)
  # ===========================================================================
  environment.systemPackages =
    with pkgs;
    [
      brightnessctl
      bluez
      bluez-tools
    ]
    ++ pkgBundle.systemPackages
    ++ pkgBundle.workstationSystemPackages;
  fonts.packages = with pkgs; [ terminus_font ];

  # ===========================================================================
  # Home packages (home-manager)
  # ===========================================================================
  home-manager.users.user = {
    home.packages = [ ] ++ pkgBundle.homePackages ++ pkgBundle.workstationHomePackages;
  };
}
