{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    image = ../../images/1668510030_kartinkin-net-p-prizrak-tsusimi-art-oboi-13.jpg;

    # Sakura (cherry blossom) + Ghost of Tsushima leaf
    # Minimal palette: grays, reddish-orange, pink tones
    base16Scheme = {
      base00 = "#1d1b1c"; # Background (dark)
      base01 = "#2d2a2b"; # Lighter background
      base02 = "#3d3839"; # Selection
      base03 = "#7d7172"; # Comments (warm gray)
      base04 = "#a89a9b"; # Dark foreground
      base05 = "#d4c7c3"; # Default foreground (warm cream)
      base06 = "#e8ddd9"; # Light foreground
      base07 = "#f5f1ed"; # Lightest foreground
      base08 = "#e25f36"; # Red (leaf orange - errors, broken links)
      base09 = "#ea7c5a"; # Orange (warm coral)
      base0A = "#e8b89e"; # Yellow (muted peach - warnings)
      base0B = "#d97b8f"; # Green→Pink (cherry blossom - executables)
      base0C = "#e89aab"; # Cyan→Salmon (light pink - info)
      base0D = "#c89aa3"; # Blue→Mauve (dusty rose - functions)
      base0E = "#c76b7e"; # Purple→Rose (deep rose - keywords)
      base0F = "#b7593d"; # Brown (leaf dark - constants)
    };

    fonts = with pkgs; {
      monospace = {
        package = nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      serif = {
        package = dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = dejavu_fonts;
        name = "DejaVu Sans";
      };
      emoji = {
        package = noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 10;
        applications = 11;
        desktop = 11;
        popups = 11;
      };
    };

    icons = {
      enable = true;
      dark = "WhiteSur-dark";
      light = "WhiteSur-light";
    };

    opacity = {
      applications = 0.9;
      terminal = 0.9;
      desktop = 0.9;
      popups = 0.9;
    };

    cursor = with pkgs; {
      package = comixcursors.Opaque_Slim_White;
      name = "ComixCursors-Opaque-Slim-White";
      size = 24;
    };
  };
  # Use modern theme engines
  home-manager.users.user = {
    home.sessionVariables = {
      # Specify GTK theme
      GTK_THEME = "WhiteSur-Dark";
      # Fix cursor jittering
      WLR_NO_HARDWARE_CURSORS = "1";
      # Hint Electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };
    stylix.targets.gtk.enable = false;
    stylix.targets.kde.enable = false;
    stylix.targets.qt.enable = false; # using Kvantum instead
    stylix.targets.firefox.profileNames = [ "default" ];

    # Set dark mode preference for XDG portal (apps query this)
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    # Kvantum theme selection
    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=WhiteSurDark
    '';

    # KDE apps read colors from kdeglobals (symlink to WhiteSurDark.colors)
    xdg.configFile."kdeglobals".source = "${pkgs.whitesur-kde}/share/color-schemes/WhiteSurDark.colors";

    gtk = {
      enable = true;
      theme = {
        name = "WhiteSur-Dark"; # or "WhiteSur-Light"
        package = pkgs.whitesur-gtk-theme;
      };
      gtk4.theme = {
        name = "WhiteSur-Dark";
        package = pkgs.whitesur-gtk-theme;
      };
    };
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum # Qt5 apps
      libsForQt5.qtstyleplugins # Qt5 GTK3 platform plugin (file dialogs)
      qt6Packages.qtstyleplugin-kvantum # Qt6 apps
      whitesur-gtk-theme
      whitesur-kde # gtk theme has kvantum files for some reason, ehh just in case tho
      whitesur-icon-theme
      lxappearance # GTK theme switcher GUI
      libsForQt5.qt5ct # Qt5 settings GUI
      qt6Packages.qt6ct # Qt6 settings GUI
    ];
  };

  # System-wide GTK settings so pkexec apps (running as root) use dark theme
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-theme-name=WhiteSur-Dark
    gtk-icon-theme-name=WhiteSur-dark
  '';
}
