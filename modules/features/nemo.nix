{ pkgs, ... }:
{
  # Enables GVFS backend for Nemo to resolve 'nfs://' URIs.
  # Also makes it look more aesthetic, idk
  # Thunar for Nemo bulk rename support
  environment.systemPackages = [ pkgs.thunar ];

  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };
  home-manager.users.user =
    { lib, ... }:
    {
      # Set nemo as default file browser
      xdg.desktopEntries.nemo = {
        name = "Nemo";
        exec = "${pkgs.nemo-with-extensions}/bin/nemo";
      };
      xdg.mimeApps = {
        defaultApplications = {
          "inode/directory" = [ "nemo.desktop" ];
          "application/x-gnome-saved-search" = [ "nemo.desktop" ];
        };
      };
      # dconf dump /
      dconf.settings = {
        # Change default terminal emulator for Nemo
        "org/cinnamon/desktop/applications/terminal".exec = "kitty";
        "org/nemo/preferences" = {
          last-server-connect-method = 0;
          # Enable terminal on toolbar
          show-open-in-terminal-toolbar = true;
          # Enable bulk rename (thunar must be installed)
          # "thunar -B" as byte array (dconf expects `ay` type)
          # @source(lib.hm): https://home-manager.dev/manual/23.05/index.html
          bulk-rename-tool = lib.hm.gvariant.mkArray lib.hm.gvariant.type.uchar [
            116
            104
            117
            110
            97
            114
            32
            45
            66
          ];
          thumbnail-limit = lib.hm.gvariant.mkUint64 104857600;
        };
        # @source: https://forums.linuxmint.com/viewtopic.php?t=431474
        "org/cinnamon/desktop/privacy" = {
          remember-recent-files = false;
        };
      };
      # Bookmarks
      # @source: https://discourse.nixos.org/t/how-to-set-the-bookmarks-in-nautilus/36143/5
      gtk.gtk3 = {
        bookmarks = [
          "file:///mnt/atlas"
        ];
      };
    };
}
