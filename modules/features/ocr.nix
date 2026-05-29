{ pkgs, ... }:
let
  # Screenshot OCR script (Nushell)
  screenshot-ocr = pkgs.writeScriptBin "screenshot-ocr"
    (builtins.readFile ../../scripts/screenshot-ocr.nu);
in
{
  # User packages (home-manager)
  home-manager.users.user = {
    home.packages = [
      screenshot-ocr
      pkgs.fuzzel # Dmenu replacement for language selection
    ];
  };
}
