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
  # lspci -nnk | grep -iA 3 net
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
      # systemd-boot is conditionally enabled by lanzaboote.nix
      # Only enable if lanzaboote is not active
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      timeout = 0; # hides boot menu, hold space during boot to bring menu up
    };
    kernelParams = [ "ip=dhcp" ];
    kernelModules = lib.mkIf isWorkstation [ "v4l2loopback" ];
    # v4l2loopback module is needed for droidcam
    extraModulePackages = lib.mkIf isWorkstation (with config.boot.kernelPackages; [ v4l2loopback ]);
    # add esoteric flags for OBS virtual camera to work
    # @source: https://nixos.wiki/wiki/OBS_Studio
    # options v4l2loopback devices=2 video_nr=10,11 card_label="DroidCam,OBS Virtual Camera" exclusive_caps=1,1
    extraModprobeConfig = lib.mkIf isWorkstation ''
       options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
    initrd = {
      # Host-specific network card modules
      availableKernelModules = networkCardModules.${hostname} or [ ];
      systemd.tpm2.enable = true; # Enable TPM2 support in initrd
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
      # @source: https://blog.decent.id/post/nixos-systemd-initrd/
      systemd.enable = true;
    };
  };
}
