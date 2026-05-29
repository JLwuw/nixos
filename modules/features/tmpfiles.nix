{
  systemd.tmpfiles = {
    rules = [
      # Journaling performs heavy writes
      # Disable Btrfs CoW to improve performance (no gazillion copies are made)
      # A warning on first boot is expected since journal directory is created BEFORE tmpfiles runs
      "h /var/log/journal - - - - +C"

      # Data partition mount points (defined in disko.nix)
      "d /mnt/aether 0755 user users -"
      "d /mnt/hermes 0755 user users -"
      "d /mnt/atlas 0755 user users -"
    ];
  };
}
