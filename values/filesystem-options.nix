{
  btrfsExtraArgs = [
    "-f"
    "--csum xxhash" # use fast hashing algorithm
  ];
  LUKSPasswordFile = "/tmp/pass"; # LUKS decryption password
  ESPPreset = {
    size = "1G";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/efi";
      mountOptions = [ "defaults" "noexec" "nosuid" "nodev" "umask=0077" ];
    };
  };
  swapContentPreset = {
    type = "swap";
    # Free unused blocks (not supported on HDDs)
    discardPolicy = "both";
    randomEncryption = true;
    # Encrypt swap as long as there is space for it
    priority = 100;
  };
  LUKSSettingsPreset = {
    # Free unused blocks (not supported on HDDs)
    allowDiscards = true;
    crypttabExtraOpts = [
      "tpm2-device=auto" # unlock LUKS using TPM chip
      "tpm2-measure-pcr=yes" # check integrity of TPM chip
    ];
  };
}
