{ config, pkgs, ... }:
{
  # Proprietary NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Needed for Nvidia systems
    modesetting.enable = true;
    # Use propietary drivers
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable NVIDIA Container Toolkit for Podman GPU access
  hardware.nvidia-container-toolkit.enable = true;

  # Build packages with CUDA support
  # make sure to enable the CUDA cache! @reference: nix-settings.nix
  nixpkgs.config.cudaSupport = true;

  hardware.graphics = {
    # Enable Hardware Accelerated Graphics
    enable = true;
    # Steam support
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      cudaPackages.cuda_cudart
    ];
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
  };
}
