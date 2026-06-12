{
  config,
  pkgs,
  lib,
  ...
}:
let
  ini = lib.generators.toINI { };
in
{
  home-manager.users.user = {
    home.packages = [ pkgs.kdePackages.okular ];

    # Window/Shell Settings
    home.file.".config/okularrc".text = ini {
      "Desktop Entry" = {
        FullScreen = false;
      };
      General = {
        LockSidebar = true;
        ShowSidebar = false;
      };
      MainWindow = {
        MenuBar = "Disabled";
      };
      UiSettings = {
        ColorScheme = "WhiteSurDark";
      };
    };
    # Document Engine Settings
    home.file.".config/okularpartrc".text = ini {
      "Main View" = {
        ShowLeftPanel = false;
      };
      "PageView" = {
        MouseMode = "TextSelect";
      };
    };
    # Set as default PDF viewer
    xdg.mimeApps = {
      defaultApplications = {
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
      };
    };
  };
}
