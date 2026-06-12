{ pkgs, ... }: {
  # GNOME Keyring for applications that need credential storage
  # Required by: Mailspring

  services.gnome.gnome-keyring.enable = true;

  # Add to system packages for CLI access
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret # For secret-tool CLI
  ];

  # PAM integration for automatic keyring unlock on login
  security.pam.services.login.enableGnomeKeyring = true;
}
