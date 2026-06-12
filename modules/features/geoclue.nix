{ ... }:
{
  # Set Geoclue as the default location provider
  location.provider = "geoclue2";

  services.geoclue2 = {
    enable = true;
  };
}
