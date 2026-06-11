{
  config,
  pkgs,
  lib,
  ...
}:
let
  hostname = config.networking.hostName;
  isWorkstation = builtins.elem config.networking.hostName [
    "laptop"
  ];
  nwDetails = import ../../values/network-details.nix;

  # Host-specific network card kernel modules
  networkCardModules = {
    laptop = [
      "iwlwifi"
      "r8169"
      "iwlmvm"
    ];
  };
in
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      timeout = 0;
    };
    kernelParams = [ "ip=dhcp" ];
    kernelModules = lib.mkIf isWorkstation [ "v4l2loopback" ];
    extraModulePackages = lib.mkIf isWorkstation (with config.boot.kernelPackages; [ v4l2loopback ]);
    extraModprobeConfig = lib.mkIf isWorkstation ''
       options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
    initrd = {
      availableKernelModules = networkCardModules.${hostname} or [ ];
      systemd.tpm2.enable = true;
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2224;
          authorizedKeys = with nwDetails; [
            laptop.ssh.pubkey
          ];
          hostKeys = [ "/persist/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
      };
      systemd.enable = true;
    };
  };
}
