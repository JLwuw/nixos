{ ... }:
{
  # Set Geoclue as the default location provider
  location.provider = "geoclue2";

  # Enable Geoclue
  services.geoclue2 = {
    enable = true;
  };
}
