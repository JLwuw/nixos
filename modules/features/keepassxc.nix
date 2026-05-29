{ ... }:
{
  home-manager.users.user = {
    programs.keepassxc = {
      enable = true;
      # Set font manually through the GUI to "small" before applying declarative settings
      # @source: https://github.com/keepassxreboot/keepassxc/blob/develop/src/core/Config.cpp
      settings = {
        General.ConfigVersion = 2;

        GUI = {
          ApplicationTheme = "dark";
          HidePasswords = true;
        };

        Security = {
          # Disable lock on session lock or lid close
          LockDatabaseScreenLock = false;
          LockDatabaseIdle = false;
        };

        Browser = {
          # NOTE: Browser integration requires manual first-time setup due to
          # Nix store being read-only (KeePassXC can't generate auth keys).
          # Enable once in GUI: Tools > Settings > Browser Integration > Enable
          Enabled = true;
          # Never ask before accessing credentials
          AlwaysAllowAccess = true;
          AlwaysAllowUpdate = true;
          SearchInAllDatabases = true;
        };
      };
    };
  };
}
