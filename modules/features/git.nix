{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Install git system-wide (available to root)
  environment.systemPackages = [ pkgs.git ];

  home-manager.users.user = {
    programs.git = {
      enable = true;
      settings = {
        core.editor = "nvim";
        user = {
          name = "yuuhikaze";
          email = "prg@yhkze.net";
        };
      };
    };
  };
}
