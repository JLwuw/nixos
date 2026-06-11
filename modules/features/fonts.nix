{ pkgs, lib, ... }: {
  # System-wide font configuration
  fonts = {
    packages = with pkgs; [
      # Noto fonts - comprehensive Unicode coverage
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      # Core fonts
      dejavu_fonts
      liberation_ttf

      # Monospace fonts
      fantasque-sans-mono
      jetbrains-mono

      # Nerd Fonts (includes icons and glyphs for terminals)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.iosevka

      # Microsoft fonts (Windows 11 style)
      # Note: These might not be available in nixpkgs due to licensing
      # corefonts # Old MS fonts (Arial, Times New Roman, etc.)
      # vistafonts # Vista/7 fonts

      # Recommended additional fonts
      inter  # Modern UI font

      # NSW ACT Foundation font (educational)
      # This might need to be manually installed if not in nixpkgs

      # Additional programming fonts
      fira-code
      fira-code-symbols
      hack-font
      source-code-pro
      iosevka

      # Emoji and symbols
      font-awesome
      material-design-icons
    ];

    # Font configuration
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Fantasque Sans Mono" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
