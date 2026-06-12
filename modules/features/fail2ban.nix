{ config, lib, ... }: {
  services.fail2ban = {
    enable = true;

    # Maximum number of failed attempts before ban
    maxretry = 5;

    # Initial ban time
    bantime = "24h";

    # Progressive ban time for repeat offenders
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # 1 week maximum
    };

    # Whitelist trusted IPs/networks
    ignoreIP = [
      "127.0.0.1/8" # Localhost
      "10.0.0.0/8" # Private network range
      "172.16.0.0/12" # Private network range
      "192.168.0.0/16" # Private network range
    ];

    # Default jail configuration
    jails = {
      # SSH jail is enabled by default
      # Additional jails can be added here for nginx, etc.
    };
  };

  # Fail2ban requires verbose SSH logging to detect failed attempts
  services.openssh.settings.LogLevel = lib.mkDefault "VERBOSE";
}
