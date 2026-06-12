{ config, lib, ... }: {
  # Gammastep configuration (Wayland-compatible redshift alternative)
  # Adjusts screen color temperature based on the sun's position
  home-manager.users.user = {
    services.gammastep = {
      enable = true;

      # Location provider (manual or geoclue2)
      provider = "geoclue2";

      # Manual location (latitude:longitude)
      # Adjust these coordinates to your location
      # Example: New York City
      # latitude = 40.7;
      # longitude = -74.0;

      # Temperature settings
      temperature = {
        day = 6500; # Daylight temperature (Kelvin)
        night = 3500; # Night temperature (Kelvin)
      };

      # Time settings (optional, uses location if not set)
      # settings = {
      #   general = {
      #     dawn-time = "6:00";
      #     dusk-time = "18:00";
      #   };
      # };
    };
  };
}
