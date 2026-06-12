{ pkgs, ... }:
let
  sysinfo-script = pkgs.writeScriptBin "sysinfo" (builtins.readFile ../../scripts/ironbar/sysinfo.nu);
in
{
  environment.systemPackages = with pkgs; [ ironbar ];

  home-manager.users.user = {
    xdg.configFile."ironbar/config.corn".text = ''
      let {
        $workspaces = {
          type = "workspaces"
          class = "module module-workspaces"
          focused_class = "focused"
          urgent_class = "urgent"
          all_monitors = true
          format = "{index}"
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

        $clock = {
          type = "clock"
          class = "module module-clock"
          format = "%d/%m/%Y %I:%M %p"
          tooltip_format = "<big>%A, %B %d, %Y</big>\n%H:%M:%S"
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
