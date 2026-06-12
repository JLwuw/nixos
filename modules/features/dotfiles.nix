{
  # Automatically backup conflicting files with .hbak extension
  home-manager.backupFileExtension = "hbak";
  # Force-overwrite any stale .hbak files instead
  # of crashing the build if they already exist
  home-manager.overwriteBackup = true;

  home-manager.users.user =
    { config, ... }:
    let
      dotfilesPath = "/home/user/dotfiles";
      neovimPath = "/home/user/nvim";
    in
    {
      # Out-of-store symlinks for configs with their own DSL
      # These are NOT copied to /nix/store - they remain mutable
      xdg.configFile = {
        "nvim".source = config.lib.file.mkOutOfStoreSymlink "${neovimPath}";
        "ironbar/style.css".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ironbar/style.css";
      };
    };

  systemd.tmpfiles.rules = [
    "d /home/user 0755 user users -"
  ];
}
