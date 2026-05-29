{ config, lib, pkgs, ... }: {
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;  # Enable experimental features like battery percentage
      };
    };
  };

  # Bluetooth service
  services.blueman.enable = true;
}
