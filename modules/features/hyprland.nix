{
  pkgs,
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

  home-manager.users.user = {
    home.packages = with pkgs; [
      uwsm # Hyprland session wrapper
      mako # notification daemon
      swayosd # on-screen display for brightness/volume
      grim # Wayland screenshot tool
      slurp # Wayland screen area selector
      grimblast # grim + slurp convenience wrapper
      pyprland # Hyprland plugins and utilities (magnify zoom)
      gromit-mpx # on-screen annotation/drawing tool
      wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste)
      hyprpicker # Hyprland color picker
    ];

    xdg.configFile."pypr/config.toml".text = ''
      [pyprland]
      plugins = ["magnify"]

      [magnify]
      factor = 2
    '';

    xdg.configFile."gromit-mpx.ini".text = ''
      [General]
      ShowIntroOnStartup=false

      [Drawing]
      Opacity=0.75
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      configType = "hyprlang"; # Lua mode broken in HM 26.05 (hyphenated keys)
      plugins = [
        (pkgs.hyprlandPlugins.hyprfocus.overrideAttrs (_: {
          src = "${hyprland-plugins-local}/hyprfocus";
        }))
      ];
      settings = {
        "$terminal" = "kitty";
        "$fileManager" = "nemo";
        "$browser" = "librewolf";
        "$music" = "spotify";
        "$messenger" = "discord";
        "$passwordManager" = "keepassxc";
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
          "uwsm app -- ironbar"
          "uwsm app -- swayosd-server"
          "uwsm app -- gromit-mpx --key none"
          "uwsm app -- pypr"
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
            "zoomFactor,1,4,easeInOutCubic"
            "hyprfocusIn,1,1.7,easeOutQuint"
            "hyprfocusOut,1,1.7,easeOutQuint"
          ];
        };

        # Dwindle layout
        dwindle = {
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

        # Input settings
        input = {
          kb_layout = "es"; # Spanish keyboard layout
          kb_options = "caps:swapescape"; # Swap Caps Lock and Escape
          repeat_rate = 50; # Key repeat rate
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

        # Window rules moved to extraConfig (block format required by 0.55+)

        # Key bindings
        bind = [
          # App launcher
          "SUPER,SPACE,exec,vicinae toggle"
          "SUPER SHIFT,w,exec,vicinae deeplink windows"

          # Applications (SUPER + key)
          "SUPER,return,exec,$terminal"

          # Window management
          "SUPER,c,killactive," # Close window
          "SUPER,f,fullscreen,0" # Fullscreen
          "SUPER SHIFT,t,pin," # Toggle keep on top
          "SUPER,p,pseudo," # Pseudotile (restored)
          # "SUPER,V,togglefloating," # Toggle floating
          "SUPER CTRL,SPACE,togglefloating," # Floating toggle
          "SUPER,w,fullscreen,1" # Maximize
          "SUPER,m,movetoworkspacesilent,special" # Minimize to special workspace

          # Center floating window
          "CTRL ALT,c,centerwindow,"

          # Focus movement (arrow keys for workspace navigation)
          "SUPER,left,workspace,e-1" # View previous workspace
          "SUPER,right,workspace,e+1" # View next workspace
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

          # Window swapping
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

          # Layout switching (with visual feedback)
          ''SUPER SHIFT,SPACE,exec,LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str' | grep -q dwindle && echo master || echo dwindle) && hyprctl keyword general:layout $LAYOUT && notify-send 'Layout' "Switched to $LAYOUT"''

          # Show desktop (view none - minimize all)
          "SUPER,d,exec,hyprctl dispatch togglespecialworkspace" # Show desktop (special workspace)

          # Move to master (swap with first window) - only works in master layout
          "SUPER SHIFT,return,layoutmsg,swapwithmaster"

          # Window cycling (ALT + TAB - system-wide)
          "ALT,Tab,cyclenext"
          "ALT SHIFT,Tab,cyclenext,prev"

          # System utilities
          ",XF86Calculator,exec,gnome-calculator"

          # Aesthetics
          ''SUPER,BACKSPACE,exec,hyprctl dispatch setprop "address:$(hyprctl activewindow -j | jq -r '.address')" opaque toggle''
          "SUPER,B,exec,ironbar bar bar-0 toggle-visible" # Toggle ironbar

          # Notifications
          "SUPER,COMMA,exec,makoctl dismiss"
          "SUPER SHIFT,COMMA,exec,makoctl dismiss --all"
          "SUPER CTRL,COMMA,exec,makoctl mode -t do-not-disturb && makoctl mode | grep -q 'do-not-disturb' && notify-send 'Silenced notifications' || notify-send 'Enabled notifications'"

          # Screenshots / OCR
          "SUPER SHIFT,s,exec,grimblast --notify copy area" # Screenshot selection to clipboard
          ",PRINT,exec,grimblast --notify save screen ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" # Fullscreen to disk
          "SHIFT,PRINT,exec,grimblast --notify save area ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" # Screenshot selection to disk
          "SUPER CTRL,s,exec,screenshot-ocr" # Screenshot → OCR → clipboard

          # Color picker
          "SUPER CTRL,PRINT,exec,pkill hyprpicker || hyprpicker -a"

          # Power/Exit menu
          "SUPER,q,exec,notify-send 'Exit Menu' 'Use wlogout or similar'" # Exit popup (TODO: implement with wlogout)
          ",XF86PowerOff,exec,notify-send 'Power Menu' 'Use wlogout or similar'" # Power button

          # Screen Lock
          "CTRL ALT,l,exec,hyprlock"

          # Window Groups
          "SUPER,G,togglegroup"

          # Screen zoom (middle-click reset)
          "SUPER,mouse:274,exec,pypr zoom"

          # Screen annotation (gromit-mpx live drawing)
          "SUPER,A,exec,gromit-mpx --toggle"
          "SUPER SHIFT,A,exec,gromit-mpx --clear"
          "SUPER CTRL,A,exec,gromit-mpx --undo"
        ];

        # Screen zoom (repeat for smooth continuous zoom)
        binde = [
          "SUPER,plus,exec,pypr zoom ++0.1"
          "SUPER,minus,exec,pypr zoom --0.1"
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
      # Window rules (block format, required by Hyprland 0.55+)
      # name = must be the first field in each block
      extraConfig = ''
        windowrule {
          name = suppress-maximize
          match:class = .*
          suppress_event = maximize
        }
        windowrule {
          name = global-opacity
          match:class = .*
          opacity = 0.97 0.9
        }
        windowrule {
          name = xwayland-no-focus
          match:class = ^$
          match:title = ^$
          match:xwayland = true
          match:float = true
          match:fullscreen = false
          match:pin = false
          no_focus = true
        }
        windowrule {
          name = terminal-scroll
          match:class = (Alacritty|kitty)
          scroll_touchpad = 1.5
        }
        windowrule {
          name = ghostty-scroll
          match:class = com.mitchellh.ghostty
          scroll_touchpad = 0.2
        }
        # Popup/context menus (empty class+title from Electron apps)
        windowrule {
          name = electron-popup
          match:class = ^()$
          match:title = ^()$
          no_blur = true
          opacity = 1.0 override
        }
        # Open-LLM-VTuber pet mode (XWayland)
        windowrule {
          name = vtuber-xwayland
          match:class = ^(open-llm-vtuber)$
          no_blur = true
          no_shadow = true
          opacity = 1.0 override
          float = true
          pin = true
        }
        # Open-LLM-VTuber pet mode (native Wayland)
        windowrule {
          name = vtuber-wayland
          match:class = ^(electron)$
          match:title = ^(Open-LLM-Vtuber)$
          no_blur = true
          no_shadow = true
          opacity = 1.0 override
          float = true
          pin = true
        }
        # Gromit-mpx (screen annotation overlay)
        windowrule {
          name = gromit-noblur
          match:class = ^(Gromit-mpx)$
          no_blur = true
          no_shadow = true
          opacity = 1.0 override
        }
        # Anki
        windowrule {
          name = anki-opacity
          match:class = ^(net.ankiweb.Anki)$
          opacity = 1.0 override
        }
        # LibreWolf
        windowrule {
          name = librewolf-opacity
          match:class = ^(LibreWolf)$
          opacity = 1.0 override
        }
        # Okular
        windowrule {
          name = okular-opacity
          match:class = ^(org.kde.okular)$
          opacity = 1.0 override
        }
        windowrule {
          name = anki-float
          match:class = ^(net.ankiweb.Anki)$
          match:title = negative:.*Anki$
          float = true
        }
      '';
    };
  };
}
