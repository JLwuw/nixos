{ config, lib, ... }: {
  # Home-manager configuration for hyprlock
  home-manager.users.user = {
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          grace = 5;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = lib.mkForce [
          {
            monitor = "";
            color = "rgb(1d1b1c)";
            blur_passes = 2;
            blur_size = 3;
          }
        ];

        input-field = lib.mkForce [
          {
            monitor = "";
            size = "300, 50";
            position = "0, -20";
            halign = "center";
            valign = "center";

            outline_thickness = 2;
            outer_color = "rgb(a89984)";
            inner_color = "rgb(1d1b1c)";
            font_color = "rgb(ebdbb2)";

            placeholder_text = "Enter Password...";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            fail_color = "rgb(fb4934)";

            rounding = 0;
            fade_on_empty = false;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 64;
            color = "rgb(ebdbb2)";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
