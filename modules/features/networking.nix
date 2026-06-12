{ config, lib, pkgs, ... }:
let
  isServer = config.networking.hostName == "server";
in
{
  networking = {
    # Hostname is set in host-specific configuration.nix
    nftables.enable = true;
    firewall.enable = true;
    # Enable NetworkManager
    networkmanager = {
      enable = true;
      # don't manage wg0 interface, systemd-networkd does
      unmanaged = [ "wg0" ];
      # Disable IPv6 privacy extensions and force MAC-based SLAAC (EUI-64)
      # This ensures stable, predictable IPv6 addresses for outgoing connections (like mail)
      connectionConfig = lib.mkIf isServer {
        "ipv6.ip6-privacy" = 0;
        "ipv6.addr-gen-mode" = "eui64"; # Force MAC-based addresses, not RFC 7217 stable-privacy
      };
    };
    # systemd-networkd for WireGuard interface only
    useNetworkd = true;
  };
  systemd.network = {
    enable = true;
    # Halt till wg0 is online
    wait-online.extraArgs = [ "--interface=wg0" ];
  };

  home-manager.users.user.home.packages = [ pkgs.networkmanagerapplet ];

  # Add user to networkmanager group
  users.users.user.extraGroups = [ "networkmanager" ];

  # Persist NetworkManager connections
  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
