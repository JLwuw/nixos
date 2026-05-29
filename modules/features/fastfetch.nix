{ config, lib, ... }:
{
  home-manager.users.user =
    { config, ... }:
    {
      programs.fastfetch = {
        enable = true;

        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

          logo = {
            type = "kitty-direct";
            source = "${../../images/7b0d7383c3c02df47ae8ea77e72ee916.png}";
            width = 24;
            padding.top = 1;
            # height = 4;
          };

          modules = [
            "break"
            {
              type = "custom";
              format = "┌─────────────────────────Hardware─────────────────────────┐";
              outputColor = "90";
            }
            {
              type = "host";
              key = "PC";
              keyColor = "green";
            }
            {
              type = "cpu";
              key = "│ ├ ";
              showPeCoreCount = true;
              keyColor = "green";
            }
            {
              type = "memory";
              key = "│ ├ ";
              keyColor = "green";
            }
            {
              type = "swap";
              key = "│ ├󱩽 ";
              keyColor = "green";
            }
            {
              type = "gpu";
              key = "│ └󰨇 ";
              keyColor = "green";
            }
            {
              type = "custom";
              format = "└──────────────────────────────────────────────────────────┘";
              outputColor = "90";
            }
            {
              type = "custom";
              format = "┌─────────────────────────Software─────────────────────────┐";
              outputColor = "90";
            }
            {
              type = "os";
              key = "OS";
              keyColor = "magenta";
            }
            {
              type = "wm";
              key = "│ ├ ";
              keyColor = "magenta";
            }
            {
              type = "kernel";
              key = "│ ├ ";
              keyColor = "magenta";
            }
            {
              type = "packages";
              key = "│ └󰏖 ";
              keyColor = "magenta";
            }
            {
              type = "custom";
              format = "└──────────────────────────────────────────────────────────┘";
              outputColor = "90";
            }
          ];
        };
      };

      # Symlink the logo file from dotfiles
      # xdg.configFile."fastfetch/xero.png".source =
      #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/fastfetch/xero.png";
    };
}
