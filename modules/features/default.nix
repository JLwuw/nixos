{
  excludedFeatures ? [ ],
  lib,
  ...
}:
let
  # Host-specific exclusions passed from flake.nix via specialArgs
  # Combined with globally disabled features
  # excludedModules = excludedFeatures ++ [ "mouse.nix" "opencloud-audit-watcher.nix" "comfyui.nix" ];
  excludedModules = excludedFeatures ++ [ "restic-backup.nix" "syncthing.nix" ];

  # Auto-import all .nix files except default.nix and excluded modules
  imports = builtins.filter (path: path != ./default.nix) (
    map (name: ./. + "/${name}") (
      builtins.filter (
        name:
        lib.hasSuffix ".nix" name                     # Must be a .nix file
        && name != "default.nix"                      # Skip this file
        && !(lib.hasPrefix "." name)                  # Skip hidden files (.syncthing.tmp)
        && !(lib.hasInfix "sync-conflict" name)       # Skip syncthing conflicts
        && !(builtins.elem name excludedModules)
      ) (builtins.attrNames (builtins.readDir ./.))
    )
  );
in
{
  imports = imports;
}
