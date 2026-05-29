{ pkgs, ... }:
{
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    # @source: https://mynixos.com/nixpkgs/option/services.locate.pruneBindMounts
    pruneBindMounts = true;
  };
}
