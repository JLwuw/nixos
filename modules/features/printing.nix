{ config, lib, pkgs, ... }: {
  # Enable CUPS for printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # Epson printer driver
      epson-escpr
      epson-escpr2

      # Additional common printer drivers
      gutenprint
      gutenprintBin
      hplip

      # PDF printer
      cups-pdf-to-pdf
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan  # Network scanner support
    ];
  };

  # Add user to scanner and printer groups
  users.users.user = {
    extraGroups = [ "lp" "scanner" ];
  };

  # Firewall rules for network printing/scanning (optional)
  # Uncomment if you need to print over network
  # networking.firewall = {
  #   allowedTCPPorts = [ 631 ];  # CUPS
  #   allowedUDPPorts = [ 631 ];  # CUPS discovery
  # };

  home-manager.users.user.home.packages = with pkgs; [
    system-config-printer # printer configuration GUI
    simple-scan # document scanning GUI
  ];

  # Persist CUPS printer state
  # Only persist /var/lib/cups (contains mutable state: printers, jobs, etc.)
  # /etc/cups is managed by NixOS as a symlink to the store - don't persist it
  environment.persistence."/persist".directories = [
    "/var/lib/cups"
  ];
}
