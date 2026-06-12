{ pkgs, ... }:
{
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Persist Flatpak packages and user data
  environment.persistence."/persist".directories = [
    "/var/lib/flatpak/" # Flatpak system packages
  ];

  home-manager.users.user.home.persistence."/persist".directories = [
    ".local/share/flatpak" # Flatpak metadata, user packages
    ".var/app" # Flatpak user data
  ];
}
