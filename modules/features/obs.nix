{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    package = pkgs.unstable.obs-studio;
    enableVirtualCamera = true;
    plugins = with pkgs.unstable.obs-studio-plugins; [
      obs-source-record
      droidcam-obs
      obs-backgroundremoval
    ];
  };
}
