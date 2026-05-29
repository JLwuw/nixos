{ ... }: {
  home-manager.users.user = {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;

      settings = {
        # Two-line prompt: info on line 1, clean input on line 2
        format = ''
          [](fg:#c76b7e)$directory[](fg:#c76b7e bg:#e25f36)$git_branch$git_status[](fg:#e25f36)$fill$cmd_duration$rust$zig$golang$python$nodejs$lua$java$c$nix_shell[](fg:#7d7172)$time[ ](fg:#7d7172)
          $character'';

        right_format = "";
        add_newline = true;

        fill.symbol = " ";

        # Directory - show only last folder, no icons
        directory = {
          format = "[ $path ]($style)";
          style = "bold fg:#1d1b1c bg:#c76b7e";
          truncation_length = 1;
          truncate_to_repo = false;
        };

        # Git branch - leaf orange
        git_branch = {
          format = "[ $symbol$branch ]($style)";
          style = "bold fg:#1d1b1c bg:#e25f36";
          symbol = " ";
        };

        # Git status
        git_status = {
          format = "[$all_status$ahead_behind]($style)";
          style = "bold fg:#1d1b1c bg:#e25f36";
          conflicted = "󰞇 ";
          ahead = "󰜷 ";
          behind = "󰜮 ";
          diverged = "󰹺 ";
          untracked = "󰋗 ";
          stashed = "󰏗 ";
          modified = "󰏫 ";
          staged = "󰸞 ";
          renamed = "󰑕 ";
          deleted = "󰆴 ";
        };

        # Disable git metrics (no +/- lines on second line)
        git_metrics.disabled = true;

        # Prompt character
        character = {
          success_symbol = "[](bold fg:#d97b8f)";
          error_symbol = "[](bold fg:#e25f36)";
          vimcmd_symbol = "[](bold fg:#c89aa3)";
        };

        # Command duration
        cmd_duration = {
          format = "[󱎫 $duration]($style) ";
          style = "fg:#7d7172";
          min_time = 2000;
        };

        # Time - rightmost
        time = {
          disabled = false;
          format = "[ $time ]($style)";
          style = "fg:#d4c7c3 bg:#7d7172";
          time_format = "%H:%M";
        };

        # Language modules - dusty mauve
        rust = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        zig = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        golang = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        python = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        nodejs = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        lua = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        java = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        c = {
          format = "[$symbol$version]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        nix_shell = {
          format = "[$symbol$state]($style) ";
          style = "fg:#c89aa3";
          symbol = " ";
        };

        # Disable unused modules
        package.disabled = true;
        line_break.disabled = true;
      };
    };
  };
}
