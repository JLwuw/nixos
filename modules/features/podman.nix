{
  # Podman containerization (replaces Docker)
  # Daemonless, rootless by default, more NixOS-native

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Provides 'docker' command alias for compatibility
    defaultNetwork.settings.dns_enabled = true;
  };

  # Add user to podman group for rootless containers
  users.users.user.extraGroups = [ "podman" ];
}
