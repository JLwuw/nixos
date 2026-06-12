{ pkgs, ... }: {
  home-manager = {
    users.user = {
      xdg.mimeApps.enable = true;
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}
