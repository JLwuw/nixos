{
  # Server
  services.openssh = {
    enable = true;
    ports = [
      22
      40351
    ];
    settings = {
      PasswordAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 40351 ];
  # Client
  programs.ssh.extraConfig = ''
    Host *
        LogLevel ERROR # Quit yapping
  '';
}
