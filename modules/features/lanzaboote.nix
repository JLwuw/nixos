{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostname = config.networking.hostName;
  # Check if marker file exists
  lanzabootePath = toString ./. + "/../../${hostname}/lanzaboote-enabled";
  lanzabooteEnabled = builtins.pathExists lanzabootePath;
in
{
  # Enable systemd-boot if lanzaboote is NOT enabled
  # Using mkForce as per Lanzaboote documentation
  boot.loader.systemd-boot.enable = lib.mkForce (!lanzabooteEnabled);

  # Enable lanzaboote if marker file exists
  boot.lanzaboote = {
    enable = lanzabooteEnabled;
    pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
