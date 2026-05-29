{ config, pkgs, lib, ... }:
let
  # Nushell scripts for ironbar
  sysinfo-script = pkgs.writeScriptBin "sysinfo"
    (builtins.readFile ../../scripts/sysinfo.nu);

  volume-script = pkgs.writeScriptBin "volume"
    (builtins.readFile ../../scripts/volume.nu);

  bt-battery-script = pkgs.writeScriptBin "bt-battery"
    (builtins.readFile ../../scripts/bt-battery.nu);

  audio-script = pkgs.writeScriptBin "audio"
    (builtins.readFile ../../scripts/audio.nu);
in {
  # Install ironbar package
  environment.systemPackages = with pkgs; [ ironbar ];

  home-manager.users.user = {
    # Create ironbar config directory and files
    xdg.configFile."ironbar/config.corn".text = ''
      let {
        $workspaces = {
          type = "workspaces"
            class = "module module-workspaces"
            focused_class = "focused"
            urgent_class = "urgent"
            all_monitors = true
            format = "{id}"
            on_click = "focus"
        }

        $sys_all = {
          type = "script"
            class = "module module-sysinfo"
            cmd = "nu ${sysinfo-script}/bin/sysinfo"
            return_type = "text"
            interval = 4000
            format = "{}"
        }

        $backlight = {
          type = "script"
            class = "module module-backlight"
            cmd = "bash -c 'echo \"󰃠 $(brightnessctl -m | cut -d, -f4)\"'"
            return_type = "text"
            interval = 1000


          on_scroll_up = "brightnessctl set +5%"
          on_scroll_down = "brightnessctl set 5%-"
        }

        $dnd = {
          type = "script"
            class = "module module-dnd"
            cmd = "bash -c 'if [ $(swaync-client --get-dnd) = true ]; then echo \"󰂛 Zen\"; else echo \"󰂚 Alert\"; fi'"
            return_type = "text"
            interval = 1000
          on_scroll_up = "swaync-client --toggle-dnd"
          on_scroll_down = "swaync-client --toggle-panel"
        }

        $volume = {
          type = "script"
            class = "module"
            cmd = "nu ${volume-script}/bin/volume"
            return_type = "text"
            interval = 1000
            on_scroll_up = "volumectl up"
            on_scroll_down = "volumectl down"
        }

        $clock = {
          type = "clock"
            class = "module module-clock"
            format = "%d/%m/%Y %I:%M %p"
            tooltip_format = "<big>%A, %B %d, %Y</big>\n%H:%M:%S"
        }

        $bt_battery = {
          type        = "script"
            class       = "module module-bt-battery"
            cmd         = "nu ${bt-battery-script}/bin/bt-battery"
            return_type = "text"
            interval    = 5000
            format      = "{}"
            on_click    = "blueman-manager"
            on_scroll_down = "${audio-script}/bin/audio next"
            on_scroll_up = "${audio-script}/bin/audio prev"
        }

        $tray = {
          type = "tray"
            class = "module module-tray"
            icon_size = 15
            spacing = 3
            direction = "h"
            blacklist = [
            "org/ayatana/NotificationItem/nm_applet"
              "org/ayatana/NotificationItem/application_indicator"
            ]
        }

        $left_widgets = [ ]
          $center_widgets = [ $workspaces $clock $sys_all ]
          $right_widgets = [ ]
      }

      in {
        position = "top"
          height = 28
          exclusive = false
          anchor_to_edges = false
          layer = "top"
          icon_theme = "Papirus"
          css_path = "~/.config/ironbar/style.css"
          name = "bar-0"

          start = $left_widgets
          center = $center_widgets
          end = $right_widgets
      }
    '';
  };
}
