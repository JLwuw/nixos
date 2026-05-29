{ config, lib, ... }:
{
  networking = {
    # Hostname is set in host-specific configuration.nix
    nftables.enable = true;
    firewall.enable = true;
    # Enable NetworkManager
    networkmanager.enable = true;
  };
  # Add user to networkmanager group
  users.users.user.extraGroups = [ "networkmanager" ];
}
