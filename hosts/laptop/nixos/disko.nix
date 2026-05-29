let filesystemOptions = import ../../../values/filesystem-options.nix;
in with filesystemOptions; {
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = ESPPreset;
            swap = {
              size = "8G";  # Larger swap for laptop (suspend to disk)
              content = swapContentPreset;
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-nvme";
                passwordFile = LUKSPasswordFile;
                settings = LUKSSettingsPreset;
                content = {
                  type = "btrfs";
                  extraArgs = btrfsExtraArgs;
                  subvolumes = let
                    btrfsMountOptions = [
                      "compress=zstd:1" # Use zstd with fastest compression level
                      "noatime" # Don't update access time metadata on files
                      "space_cache=v2" # Cache free blocks
                      "ssd" # Explicit SSD optimization
                    ];
                  in {
                    "/@root" = {
                      mountpoint = "/";
                      mountOptions = btrfsMountOptions;
                    };
                    "/@nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsMountOptions;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
