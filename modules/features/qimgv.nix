{ pkgs, ... }:
{
  home-manager.users.user = {
    home.packages = [ pkgs.qimgv ];

    xdg.mimeApps = {
      defaultApplications = {
        "image/tiff" = [ "qimgv.desktop" ];
        "image/svg+xml" = [ "qimgv.desktop" ];
        "image/bmp" = [ "qimgv.desktop" ];
        "image/gif" = [ "qimgv.desktop" ];
        "image/jpeg" = [ "qimgv.desktop" ];
        "image/png" = [ "qimgv.desktop" ];
        "image/webp" = [ "qimgv.desktop" ];
        "image/x-icns" = [ "qimgv.desktop" ];
      };
    };
  };
}
