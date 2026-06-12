{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.distrobox ];
  # Configure distrobox to mount required paths into all containers
  # /persist - Access to persistent btrfs subvolume
  # /nix/store - Read-only access to Nix store (required for distrobox entrypoint on NixOS)
  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/persist:/persist /nix/store:/nix/store:ro"
  '';
}
