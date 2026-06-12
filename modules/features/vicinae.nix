{
  ...
}:
{
  # Vicinae launcher daemon
  home-manager.users.user = {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
      settings = {
        # Add any vicinae-specific settings here
      };
    };
  };
}
