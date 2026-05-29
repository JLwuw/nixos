{ config, pkgs, lib, ... }:
let
  # Patch kitty to disable Wayland color management protocol
  # Workaround for wp_color_manager_v1 "CM Surface already exists" error
  # See: https://github.com/kovidgoyal/kitty/issues/9030
  kitty-patched = pkgs.kitty.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      # Disable color management support to work around Hyprland bug
      substituteInPlace glfw/wl_window.c \
        --replace-fail "if (_glfw.wl.color_manager.has_needed_capabilities) {" \
                       "if (false && _glfw.wl.color_manager.has_needed_capabilities) {"
    '';
  });
in {
  home-manager.users.user = {
    programs.kitty = {
      enable = true;
      package = kitty-patched;

      # Font settings (family and size comes from Stylix)
      # font.size = ...;
      # font.family = ...;

      settings = {
        # Wayland backend (Hyprland)
        linux_display_server = "wayland";

        # Font adjustments
        adjust_line_height = 4;

        # Cursor
        cursor_shape = "beam";
        cursor_blink_interval = 0;

        # Opacity (dynamic control)
        dynamic_background_opacity = true;

        # Keybindings
        kitty_mod = "alt";
        enabled_layouts = "splits:split_axis=horizontal, stack";

        # Window settings
        hide_window_decorations = true;
        window_border_width = 0;
        window_padding_width = 0;
        active_border_color = "none";
        placement_strategy = "top-left";

        # Tab bar style
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        # Miscellaneous
        enable_audio_bell = false;
        paste_actions = "quote-urls-at-prompt";
        allow_remote_control = true;
        term = "xterm-256color";
        scrollback_lines = 10000;
        sync_to_monitor = true;
        confirm_os_window_close = -1;
      };

      # Keybindings
      keybindings = {
        # Clipboard
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "ctrl+shift+s" = "paste_from_selection";

        # Tabs
        "kitty_mod+t" = "new_tab";
        "kitty_mod+q" = "close_tab";
        "kitty_mod+shift+j" = "next_tab";
        "kitty_mod+shift+k" = "previous_tab";
        "ctrl+shift+." = "move_tab_forward";
        "ctrl+shift+," = "move_tab_backward";

        # Windows
        "kitty_mod+d" = "close_window";
        "kitty_mod+w" = "toggle_layout stack";
        "kitty_mod+e" = "launch --location=hsplit --cwd=current";
        "kitty_mod+v" = "launch --location=vsplit --cwd=current";
        "kitty_mod+tab" = "next_window";
        "kitty_mod+shift+tab" = "previous_window";
        "kitty_mod+j" = "neighboring_window bottom";
        "kitty_mod+k" = "neighboring_window top";
        "kitty_mod+h" = "neighboring_window left";
        "kitty_mod+l" = "neighboring_window right";

        # Window resizing
        "kitty_mod+right" = "resize_window wider";
        "kitty_mod+left" = "resize_window narrower";
        "kitty_mod+up" = "resize_window taller";
        "kitty_mod+down" = "resize_window shorter";

        # Font size
        "kitty_mod+shift+up" = "increase_font_size";
        "kitty_mod+shift+down" = "decrease_font_size";
        "kitty_mod+0" = "restore_font_size";

        # Opacity control
        "kitty_mod+shift+left" = "set_background_opacity -0.03";
        "kitty_mod+shift+right" = "set_background_opacity +0.03";

        # Overlays and hints
        "kitty_mod+f" = "launch --type=overlay --stdin-source=@screen_scrollback fzf --color 'bg+:#303030,gutter:-1' --no-sort --no-mouse --exact -i --tac";
        "kitty_mod+p" = "launch --type=overlay --stdin-source=@screen_scrollback nvim +'silent! g/^$/d' +'normal G' +'normal zb' +'setf log' +'set showmode' +':%s/\\s\\+$//e'";
        "kitty_mod+m" = "launch --type=overlay --stdin-source=@screen_scrollback nvim +'normal G' +'normal zb' +'setf log' +'set showmode' +':%s/\\s\\+$//e'";
        "kitty_mod+i" = "kitten hints --type word --program -";
        "kitty_mod+y" = "kitten hints --type path --program -";

        # Config reload
        "kitty_mod+r" = "load_config_file";

        # Broadcast
        "kitty_mod+b" = "launch kitty +kitten broadcast --match-tab state:focused";
        "kitty_mod+s" = "launch kitty +kitten broadcast --match var:TRGT=1";

        # Special text input
        "shift+enter" = "send_text all \\x1b[13;2u";
        "ctrl+enter" = "send_text all \\x1b[13;5u";
        "kitty_mod+n" = "send_text normal  tern-core\\n";
        "kitty_mod+shift+n" = "send_text normal  tern-core -s\\n";

        # Disabled mappings
        "ctrl+tab" = "no_op";
        "ctrl+shift+tab" = "no_op";
      };

      # Mouse mappings
      extraConfig = ''
        mouse_map left click ungrabbed no_op
      '';
    };
  };
}
