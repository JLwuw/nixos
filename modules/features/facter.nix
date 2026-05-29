{ config, ... }:
let
  hostname = config.networking.hostName;
  facterPaths = {
    laptop = ../../hosts/laptop/facter.json;
  };
  facterPath = facterPaths.${hostname} or (throw "Unknown host: ${hostname}");
in {
  config.facter.reportPath = facterPath;
}
