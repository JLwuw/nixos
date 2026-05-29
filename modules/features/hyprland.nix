{
  pkgs,
  hyprland-easymotion,
  hyprland-plugins-local,
  ...
}:
{
  # NixOS-level Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager - greetd with auto-login for remote access via Sunshine
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start -F hyprland.desktop";
        user = "user";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start -F hyprland.desktop'";
        user = "greeter";
      };
    };
  };

  # Required for home-manager xdg.portal
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  security.pam.services.hyprlock = { };

  # Home-manager configuration for user
  home-manager.users.user = {
    # Vicinae launcher daemon
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

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      plugins = [
        (pkgs.hyprlandPlugins.hyprfocus.overrideAttrs (_: {
          src = "${hyprland-plugins-local}/hyprfocus";
        }))
        # hyprland-easymotion pending upstream fix for 0.52 compat
      ];
      settings = {
        "$terminal" = "kitty";
        "$fileManager" = "nemo";
        "$browser" = "librewolf";
        "$music" = "spotify"; # or whatever you use
        "$messenger" = "discord"; # or whatever you use
        "$passwordManager" = "keepassxc"; # or whatever you use
        # Environment variables
        env = [
          "WAYLAND_DISPLAY,wayland-1"
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "GDK_BACKEND,wayland,x11,*"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_STYLE_OVERRIDE,kvantum"
          "SDL_VIDEODRIVER,wayland"
          "MOZ_ENABLE_WAYLAND,1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
          "OZONE_PLATFORM,wayland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XCOMPOSEFILE,~/.XCompose"
        ];

        # Monitor configuration
        monitor = [ ",preferred,auto,auto" ];

        # XWayland settings
        xwayland = {
          force_zero_scaling = true;
        };

        # Ecosystem settings
        ecosystem = {
          no_update_news = true;
        };

        # Autostart applications
        exec-once = [
          "hyprlock" # Lock immediately for remote access security
          "uwsm app -- mako"
          # "uwsm app -- waybar"  # Replaced with ironbar
          "uwsm app -- ironbar"
          "uwsm app -- swayosd-server"
        ];

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 0; # Disabled borders
          # "col.active_border" = lib.mkForce "rgb(c76b7e)";  # Vibrant leaf orange (sakura palette)
          # "col.inactive_border" = lib.mkForce "rgba(c76b7e66)";  # Vibrant leaf at 40% opacity
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        # Render settings
        # @source: https://github.com/hyprwm/Hyprland/discussions/12829
        # Prevents washed out colors in certain programs on fullscreen (e.g. mpv)
        render = {
          cm_fs_passthrough = 0;
          cm_auto_hdr = 0;
        };

        # Decoration settings
        decoration = {
          rounding = 0;

          shadow = {
            enabled = true;
            range = 2;
            render_power = 3;
            # color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
            popups = true;
            popups_ignorealpha = 0.2;
          };
        };

        # Animation settings
        animations = {
          enabled = true;

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global,1,10,default"
            "border,1,5.39,easeOutQuint"
            "windows,1,4.79,easeOutQuint"
            "windowsIn,1,4.1,easeOutQuint,popin 87%"
            "windowsOut,1,1.49,linear,popin 87%"
            "fadeIn,1,1.73,almostLinear"
            "fadeOut,1,1.46,almostLinear"
            "fade,1,3.03,quick"
            "layers,1,3.81,easeOutQuint"
            "layersIn,1,4,easeOutQuint,fade"
            "layersOut,1,1.5,linear,fade"
            "fadeLayersIn,1,1.79,almostLinear"
            "fadeLayersOut,1,1.39,almostLinear"
            "workspaces,0,0,ease"
            "hyprfocusIn,1,1.7,easeOutQuint"
            "hyprfocusOut,1,1.7,easeOutQuint"
          ];
        };

        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # Master layout
        master = {
          new_status = "master";
        };

        # Misc settings
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = true;
        };

        # Cursor settings
        cursor = {
          hide_on_key_press = true;
          no_hardware_cursors = true;
        };

        # Input settings (from Awesome config)
        input = {
          # OLD CONFIG (pre-Awesome migration):
          # kb_options = "compose:caps";
          # repeat_rate = 40;

          # NEW CONFIG (Awesome-style):
          kb_layout = "es"; # Spanish keyboard layout
          kb_options = "caps:swapescape"; # Swap Caps Lock and Escape
          repeat_rate = 50; # Key repeat rate (from awesome: xset r rate 300 50)
          repeat_delay = 300; # Key repeat delay
          numlock_by_default = true;

          touchpad = {
            natural_scroll = false;
            scroll_factor = 0.4;
          };
        };
        # Hyprfocus plugin configuration
        # keyboard/mouse_focus_animation: flash | shrink | slide | none
        plugin = {
          hyprfocus = {
            enable = true;
            animate_floating = false;
            keyboard_focus_animation = "slide";
            mouse_focus_animation = "none";
            slide_height = 15;
          };
        };

        # Window rules
        windowrule = [
          "suppressevent maximize,class:.*"
          "opacity 0.97 0.9,class:.*"
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          "scrolltouchpad 1.5,class:(Alacritty|kitty)"
          "scrolltouchpad 0.2,class:com.mitchellh.ghostty"
        ];

        # Window rules v2 (advanced format)
        windowrulev2 = [
          # Disable blur for popup/context menus (empty class/title - Electron apps)
          "noblur,class:^()$,title:^()$"
          # Reset opacity to prevent global rule interference
          "opacity 1.0 override,class:^()$,title:^()$"

          # Open-LLM-VTuber pet mode (XWayland fallback: class=open-llm-vtuber)
          "noblur,class:^(open-llm-vtuber)$"
          "noshadow,class:^(open-llm-vtuber)$"
          "opacity 1.0 override,class:^(open-llm-vtuber)$"
          "float,class:^(open-llm-vtuber)$"
          "pin,class:^(open-llm-vtuber)$"
          # Open-LLM-VTuber pet mode (native Wayland: class=electron, title=Open-LLM-Vtuber)
          "noblur,class:^(electron)$,title:^(Open-LLM-Vtuber)$"
          "noshadow,class:^(electron)$,title:^(Open-LLM-Vtuber)$"
          "opacity 1.0 override,class:^(electron)$,title:^(Open-LLM-Vtuber)$"
          "float,class:^(electron)$,title:^(Open-LLM-Vtuber)$"
          "pin,class:^(electron)$,title:^(Open-LLM-Vtuber)$"

          # ANKI
          "opacity 1.0 override,class:^(net.ankiweb.Anki)$"
          # Float any Anki window IF its title does NOT end with "Anki"
          "float,class:^(net.ankiweb.Anki)$,title:negative:.*Anki$"
        ];

        # Key bindings
        bind = [
          # App launcher
          # OLD: "SUPER,SPACE,exec,rofi -show drun -show-icons"
          # OLD: "SUPER,SPACE,exec,wofi --show drun"
          "SUPER,SPACE,exec,vicinae toggle"
          "SUPER SHIFT,w,exec,vicinae deeplink windows"

          # Applications (SUPER + key)
          "SUPER,return,exec,$terminal"

          # OLD APPLICATION BINDINGS (pre-Awesome migration):
          # "SUPER,F,exec,$fileManager"
          # "SUPER,B,exec,$browser"
          # "SUPER,M,exec,$music"
          # "SUPER,N,exec,$terminal -e nvim"
          # "SUPER,T,exec,$terminal -e btop"
          # "SUPER,D,exec,$terminal -e lazydocker"
          # "SUPER,G,exec,$messenger"
          # "SUPER,slash,exec,$passwordManager"

          # Awesome-style prompts (using vicinae)
          "SUPER,x,exec,vicinae deeplink shell" # Execute prompt (like awesome lua exec)
          "SUPER,r,exec,vicinae toggle" # Run command prompt

          # Action center / utilities
          "SUPER,a,exec,notify-send 'Action Center' 'Not implemented yet'" # TODO: implement action center
          "SUPER SHIFT,s,exec,grimblast --notify copy area"

          # Scratchpad terminal
          # "SUPER,s,exec,$terminal --class scratch"  # TODO: setup scratchpad

          # Window management (Awesome-style)
          "SUPER,c,killactive," # Close window (was SUPER+W in old config)
          "SUPER,f,fullscreen,0" # Fullscreen (Awesome-style)
          "SUPER SHIFT,t,pin," # Toggle keep on top (closest to awesome ontop)
          "SUPER,p,pseudo," # Pseudotile (restored)
          # "SUPER,V,togglefloating," # Toggle floating
          "SUPER CTRL,SPACE,togglefloating," # Awesome-style floating toggle
          "SUPER,w,fullscreen,1" # Maximize (Awesome-style, using fullscreen mode 1)
          "SUPER,m,movetoworkspacesilent,special" # Minimize to special workspace (Awesome-style)

          # OLD WINDOW MANAGEMENT (pre-Awesome migration):
          # "SUPER,W,killactive,"
          # "SUPER,J,togglesplit,"
          # "SUPER,P,pseudo,"
          # "SHIFT,F11,fullscreen,0"
          # "ALT,F11,fullscreen,1"

          # Center floating window
          "CTRL ALT,c,centerwindow,"

          # Focus movement (Awesome j/k style)
          # "SUPER,j,cyclenext," # Focus next by index
          # "SUPER,k,cyclenext,prev" # Focus previous by index
          # "SUPER,TAB,focuscurrentorlast," # Go back (focus history)

          # OLD FOCUS MOVEMENT (pre-Awesome migration):
          # Arrow keys:
          # "SUPER,left,movefocus,l"
          # "SUPER,right,movefocus,r"
          # "SUPER,up,movefocus,u"
          # "SUPER,down,movefocus,d"
          # Vim keys:
          # "SUPER,H,movefocus,l"
          # "SUPER,L,movefocus,r"
          # "SUPER,K,movefocus,u"
          # "SUPER,J,movefocus,d"

          # Focus movement (arrow keys for workspace navigation)
          "SUPER,left,workspace,e-1" # View previous workspace (like awesome tag)
          "SUPER,right,workspace,e+1" # View next workspace (like awesome tag)
          "SUPER,ESCAPE,workspace,previous" # Go back (workspace history)

          # Workspace switching (number keys)
          "SUPER,1,workspace,1"
          "SUPER,2,workspace,2"
          "SUPER,3,workspace,3"
          "SUPER,4,workspace,4"
          "SUPER,5,workspace,5"
          "SUPER,6,workspace,6"
          "SUPER,7,workspace,7"
          "SUPER,8,workspace,8"
          "SUPER,9,workspace,9"
          "SUPER,0,workspace,10"

          # Move to workspace (SUPER + SHIFT + number)
          "SUPER SHIFT,1,movetoworkspace,1"
          "SUPER SHIFT,2,movetoworkspace,2"
          "SUPER SHIFT,3,movetoworkspace,3"
          "SUPER SHIFT,4,movetoworkspace,4"
          "SUPER SHIFT,5,movetoworkspace,5"
          "SUPER SHIFT,6,movetoworkspace,6"
          "SUPER SHIFT,7,movetoworkspace,7"
          "SUPER SHIFT,8,movetoworkspace,8"
          "SUPER SHIFT,9,movetoworkspace,9"
          "SUPER SHIFT,0,movetoworkspace,10"

          # OLD WORKSPACE NAVIGATION (pre-Awesome migration):
          # "SUPER,TAB,workspace,e+1"  # Next workspace with TAB
          # "SUPER SHIFT,TAB,workspace,e-1"  # Previous workspace with SHIFT+TAB
          # "SUPER CTRL,TAB,workspace,previous"  # Workspace history

          # Window swapping (Awesome j/k style)
          "SUPER CTRL,j,swapnext," # Swap with next client
          "SUPER CTRL,k,swapnext,prev" # Swap with previous client

          # Vim-style Focus movement (SUPER + hjkl)
          "SUPER,h,movefocus,l"
          "SUPER,l,movefocus,r"
          "SUPER,k,movefocus,u"
          "SUPER,j,movefocus,d"

          # Vim-style Window resizing (SUPER + SHIFT + hjkl)
          "SUPER SHIFT,h,resizeactive,-100 0"
          "SUPER SHIFT,l,resizeactive,100 0"
          "SUPER SHIFT,k,resizeactive,0 -100"
          "SUPER SHIFT,j,resizeactive,0 100"

          # OLD WINDOW RESIZING (pre-Awesome migration):
          # "SUPER,minus,resizeactive,-100 0"
          # "SUPER,equal,resizeactive,100 0"
          # "SUPER SHIFT,minus,resizeactive,0 -100"
          # "SUPER SHIFT,equal,resizeactive,0 100"

          # Master/stack adjustments (commented - not directly applicable to Hyprland dwindle)
          # "SUPER SHIFT,h,..."  # Increase number of master clients
          # "SUPER SHIFT,l,..."  # Decrease number of master clients
          # "SUPER CTRL,h,..."  # Increase number of columns
          # "SUPER CTRL,l,..."  # Decrease number of columns

          # Layout switching (with visual feedback)
          ''SUPER SHIFT,SPACE,exec,LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str' | grep -q dwindle && echo master || echo dwindle) && hyprctl keyword general:layout $LAYOUT && notify-send 'Layout' "Switched to $LAYOUT"''

          # Show desktop (view none - minimize all)
          "SUPER,d,exec,hyprctl dispatch togglespecialworkspace" # Show desktop (special workspace)

          # Move to master (swap with first window) - only works in master layout
          "SUPER SHIFT,return,layoutmsg,swapwithmaster"

          # Urgent client jump (not directly supported, using scratchpad as alternative)
          # "SUPER,u,..."  # Jump to urgent client

          # Window cycling (ALT + TAB - system-wide)
          "ALT,Tab,cyclenext"
          "ALT SHIFT,Tab,cyclenext,prev"

          # OLD WINDOW CYCLING (pre-Awesome migration):
          # "ALT,Tab,bringactivetotop"  # This was duplicate
          # "ALT SHIFT,Tab,bringactivetotop"

          # Mouse workspace scrolling
          "SUPER,mouse_down,workspace,e+1"
          "SUPER,mouse_up,workspace,e-1"

          # Screen rotation (commented - X11 specific, use wl-randr on Wayland if needed)
          # "SUPER CTRL,left,exec,wl-randr --output <output> --transform 90"  # Rotate left
          # "SUPER CTRL,right,exec,wl-randr --output <output> --transform 270"  # Rotate right
          # "SUPER CTRL,up,exec,wl-randr --output <output> --transform normal"  # Normal orientation
          # "SUPER CTRL,down,exec,wl-randr --output <output> --transform 180"  # Upside down

          # System utilities
          ",XF86Calculator,exec,gnome-calculator"

          # Aesthetics
          ''SUPER,BACKSPACE,exec,hyprctl dispatch setprop "address:$(hyprctl activewindow -j | jq -r '.address')" opaque toggle''
          # "SUPER ALT,b,exec,pkill -SIGUSR1 waybar"  # Toggle waybar (replaced with ironbar)
          "SUPER,B,exec,ironbar bar bar-0 toggle-visible" # Toggle ironbar

          # OLD AESTHETICS (pre-Awesome migration):
          # "SUPER SHIFT,SPACE,exec,pkill -SIGUSR1 waybar"  # Toggle waybar (moved to SUPER+ALT+b)

          # Notifications
          "SUPER,COMMA,exec,makoctl dismiss"
          "SUPER SHIFT,COMMA,exec,makoctl dismiss --all"
          "SUPER CTRL,COMMA,exec,makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send 'Silenced notifications' || notify-send 'Enabled notifications'"

          # Screenshots (Awesome-style with grim + slurp)
          ",PRINT,exec,grimblast --notify save screen ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
          "SHIFT,PRINT,exec,grimblast --notify save area ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" # Screenshot selection to clipboard

          # OLD SCREENSHOTS (pre-Awesome migration):
          # ",PRINT,exec,grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot copied'"  # Selection to clipboard
          # "SHIFT,PRINT,exec,grim -g \"$(hyprctl activewindow -j | jq -r '.at,.size' | tr -d '[]' | awk '{printf \"%d,%d %dx%d\", $1, $2, $3, $4}')\" - | wl-copy && notify-send 'Window screenshot copied'"  # Active window to clipboard
          # "CTRL,PRINT,exec,grim - | wl-copy && notify-send 'Full screen screenshot copied'"  # Full screen to clipboard
          # "SUPER,PRINT,exec,pkill hyprpicker || hyprpicker -a"  # Color picker

          # Color picker
          "SUPER CTRL,PRINT,exec,pkill hyprpicker || hyprpicker -a"

          # Power/Exit menu
          "SUPER,q,exec,notify-send 'Exit Menu' 'Use wlogout or similar'" # Exit popup (TODO: implement with wlogout)
          ",XF86PowerOff,exec,notify-send 'Power Menu' 'Use wlogout or similar'" # Power button

          # OLD POWER MENU (pre-Awesome migration):
          # "SUPER,ESCAPE,exec,rofi -show power-menu -modi power-menu:rofi-power-menu"

          # Screen Lock
          "CTRL ALT,l,exec,hyprlock"

          # Window Groups
          "SUPER,G,togglegroup"

          # Screen zoom (Windows-style magnifier)
          "SUPER,plus,exec,hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 0.5')"
          "SUPER,minus,exec,hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '[.float - 0.5, 1] | max')"
          "CTRL ALT,0,exec,hyprctl keyword cursor:zoom_factor 1"

          # EasyMotion
          # "SUPER, TAB, easymotion, action:hyprctl dispatch focuswindow address:{}"
          # Optional: Customize easymotion behavior
          # "SUPER SHIFT, z, easymotion, action:hyprctl dispatch killactive"  # Kill window
          # "SUPER, x, easymotion, action:hyprctl dispatch movetoworkspace {}" # Move to WS
        ];

        # Mouse bindings
        bindm = [
          "SUPER,mouse:272,movewindow"
          "SUPER,mouse:273,resizewindow"
        ];

        # Media keys (locked — work even when input is inhibited)
        bindl = [
          ",XF86AudioNext,exec,$osdclient --playerctl next"
          ",XF86AudioPause,exec,$osdclient --playerctl play-pause"
          ",XF86AudioPlay,exec,$osdclient --playerctl play-pause"
          ",XF86AudioPrev,exec,$osdclient --playerctl previous"
          ",XF86AudioMute,exec,$osdclient --output-volume mute-toggle"
          ",XF86AudioMicMute,exec,$osdclient --input-volume mute-toggle"
        ];

        # Volume and brightness (locked + repeat)
        bindel = [
          ",XF86AudioRaiseVolume,exec,$osdclient --output-volume raise"
          ",XF86AudioLowerVolume,exec,$osdclient --output-volume lower"
          ",XF86MonBrightnessUp,exec,$osdclient --brightness raise"
          ",XF86MonBrightnessDown,exec,$osdclient --brightness lower"
          "ALT,XF86AudioRaiseVolume,exec,$osdclient --output-volume +1"
          "ALT,XF86AudioLowerVolume,exec,$osdclient --output-volume -1"
          "ALT,XF86MonBrightnessUp,exec,$osdclient --brightness +1"
          "ALT,XF86MonBrightnessDown,exec,$osdclient --brightness -1"
        ];

        # Variables for commands
        "$osdclient" =
          ''swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"'';
      };
    };
  };
}
