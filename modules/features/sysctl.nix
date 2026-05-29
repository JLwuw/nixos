{ config, lib, ... }:
let
  isServer = config.networking.hostName == "server";
in
{
  boot.kernel.sysctl = {
    # ==================================================================
    # Reduce swappiness (default 60, lower = prefer RAM over swap)
    # Server: 20 (stability, graceful degradation under load)
    # Workstations: 10 (responsiveness for interactive use)
    "vm.swappiness" = if isServer then 20 else 10;
    # ==================================================================
    # Enable REISUB
    "kernel.sysrq" = 1;
    # ==================================================================
    # Detect MTU automatically
    # Prevents flakiness due to incorrect MTU assumptions
    "net.ipv4.tcp_mtu_probing" = 1;
    # ==================================================================
    # Enable packet forwarding (master switch, required for NAT/routing)
    "net.ipv4.ip_forward" = true;
    # Whitelist mode: disable forwarding by default, enable per-interface
    "net.ipv4.conf.all.forwarding" = false;
    "net.ipv4.conf.default.forwarding" = false;
    # Enable forwarding for Incus bridge (provides internet access to VMs)
    "net.ipv4.conf.incusbr0.forwarding" = true;
    # Enable forwarding for Wireguard (server acts as VPN router)
    "net.ipv4.conf.wg0.forwarding" = isServer;
    # ==================================================================
    # Allow services to bind to IP addresses even if the network interface for them hasn't finished booting yet
    "net.ipv4.ip_nonlocal_bind" = 1;
    # ==================================================================
  };
}
