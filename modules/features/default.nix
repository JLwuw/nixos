{
  bootstrap ? false,
  includedFeatures,
  lib,
  ...
}:
let
  bootstrapFeatures = import ../../values/bootstrap.nix;

  selected = if bootstrap then bootstrapFeatures else includedFeatures;

  validNames = builtins.filter (
    name:
    lib.hasSuffix ".nix" name
    && name != "default.nix"
    && !(lib.hasPrefix "." name)
    && !(lib.hasInfix "sync-conflict" name)
  ) (builtins.attrNames (builtins.readDir ./.));

  unknown = lib.subtractLists validNames selected;

  toImport = builtins.filter (name: builtins.elem name selected) validNames;
in
{
  imports = lib.throwIf (unknown != [ ])
    "modules/features: unknown feature(s) requested: ${lib.concatStringsSep ", " unknown}"
    (map (name: ./. + "/${name}") toImport);
}
