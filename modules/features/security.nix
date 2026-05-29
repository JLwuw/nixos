{ pkgs, ... }:
{
  security = {
    # Enable AppArmor for system and container security
    apparmor.enable = true;
    # Enable Polkit (needed for GParted)
    polkit.enable = true;
    # tpm2.enable = true;
    # Expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    # tpm2.pkcs11.enable = true;
    # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    # tpm2.tctiEnvironment.enable = true;
    sudo = {
      extraConfig = ''
        # Suppress nagging when escalating to superuser
        Defaults lecture = never
      '';
      wheelNeedsPassword = false;
    };
  };

  # Polkit authentication agent - required for GUI privilege escalation
  # GParted uses pkexec which requires an agent to display the auth dialog
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
