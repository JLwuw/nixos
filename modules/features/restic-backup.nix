{ config, ... }:
{
  # Restic backup to Backblaze B2
  # Encrypted, deduplicated backups with GFS retention

  # SOPS secrets for Restic and B2 credentials
  sops.secrets."restic/password" = {
    restartUnits = [ "restic-backups-server-b2.service" ];
  };

  sops.secrets."restic/b2-credentials" = {
    restartUnits = [ "restic-backups-server-b2.service" ];
  };

  services.restic.backups.server-b2 = {
    initialize = true;

    # B2 repository format: b2:<bucket-name>:<repository-path>
    # Example: b2:my-backup-bucket:server-backups
    repository = "PLACEHOLDER";

    # Paths to backup
    paths = [
      # Define your back up paths here!
    ];

    # Exclusion patterns (gitignore-like syntax)
    exclude = [
      # Python
      "**/__pycache__"
      "**/*.pyc"

      # Node.js
      "**/node_modules"

      # Build artifacts
      "**/build"
      "**/dist"
      "**/target"
      "**/zig-out"
      "**/zig-pkg"

      # Flutter/Dart
      "**/.dart_tool"
      "**/.flutter-plugins-dependencies"
      "**/platforms/android/build"
      "**/platforms/ios/build"

      # Cache
      "**/.cache"
      "**/cache"
      "**/.zig-cache"

      # Temporary files
      "**/*.tmp"
      "**/tmp"

      # LaTeX artifacts
      "**/*.aux"
      "**/*.log"
      "**/*.out"
      "**/*.toc"
      "**/*.lof"
      "**/*.lot"
      "**/*.fls"
      "**/*.fdb_latexmk"
      "**/*.synctex.gz"
      "**/*.bbl"
      "**/*.blg"

      # Syncthing
      "**/.syncthing.*.tmp"
      "**/*sync-conflict-*"
    ];

    # Schedule: Daily at 3AM
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true; # Run after boot if missed
      RandomizedDelaySec = "5m";
    };

    # GFS retention policy
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-monthly 3"
      "--keep-yearly 2"
    ];

    # Credentials from SOPS
    passwordFile = config.sops.secrets."restic/password".path;
    environmentFile = config.sops.secrets."restic/b2-credentials".path;
  };
}
