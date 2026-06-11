{ pkgs, lib, bootstrap ? false, ... }:
let
  corePkgs = import ../../../values/packages/core.nix { inherit pkgs; };
  workstationPkgs =
    if bootstrap then
      { systemPackages = [ ]; homePackages = [ ]; }
    else
      import ../../../values/packages/workstation.nix { inherit pkgs; };
in
{
  environment.systemPackages =
    (with pkgs; [
      brightnessctl # backlight/brightness control
      bluez # Bluetooth stack
      bluez-tools # Bluetooth management tools
    ])
    ++ corePkgs.systemPackages
    ++ workstationPkgs.systemPackages;
  fonts.packages = with pkgs; [ terminus_font ];

  home-manager.users.user = {
    home.packages = workstationPkgs.homePackages;
  };
}
