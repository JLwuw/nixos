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

  # Persist Podman data (containers, images, volumes)
  environment.persistence."/persist".directories = [
    "/var/lib/containers" # Containers
    "/etc/containers/networks" # Networks
  ];

  # Persist rootless Podman data (user containers)
  home-manager.users.user.home.persistence."/persist" = {
    directories = [
      ".local/share/containers" # Rootless container storage (images, containers, volumes)
    ];
  };
}
