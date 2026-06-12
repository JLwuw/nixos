{ config, lib, ... }:
let
  facterPath = ../../hosts/laptop/facter.json;
in {
  config.facter.reportPath = lib.mkIf (builtins.pathExists facterPath) facterPath;
}
