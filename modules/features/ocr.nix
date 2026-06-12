{ pkgs, ... }:
let
  # Screenshot OCR script (Nushell)
  screenshot-ocr = pkgs.writeScriptBin "screenshot-ocr"
    (builtins.readFile ../../scripts/screenshot-ocr.nu);
in
{
  # System packages
  environment.systemPackages = with pkgs; [
    tesseract # OCR engine
    tesseract5 # latest OCR engine
  ];

  # User packages (home-manager)
  home-manager.users.user = {
    home.packages = [
      screenshot-ocr
      pkgs.fuzzel # Dmenu replacement for language selection
    ];
  };
}
