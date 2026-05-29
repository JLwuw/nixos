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

  # Enable scanner support
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
}
