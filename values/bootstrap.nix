# Feature whitelist for one-shot bootstrap deploys.
#
# Selected when BOOTSTRAP=1 is set in the environment (see flake.nix). Replaces
# the host's normal `includedFeatures` list so the install-phase tmpfs of
# nixos-anywhere doesn't OOM on heavy services. After first boot, run a normal
# `nixos-rebuild switch --flake 'path:.#<host>'` (without BOOTSTRAP) to converge
# to the full configuration on the installed disk.
#
# Modules listed here must be sufficient to:
#   - boot the host (bootloader, hardware, locale, tmpfiles)
#   - reach the host over SSH on its LAN address (networking, openssh)
#   - log in as `user` with the SOPS-backed password (sops, users, shell)
#   - run nixos-rebuild against the full flake (nix-settings for substituters,
#     garbage-collector, facter for hardware report path)
[
  "bootloader.nix"
  "facter.nix"
  "garbage-collector.nix"
  "hardware.nix"
  "lanzaboote.nix"
  "locale.nix"
  "networking.nix"
  "nix-settings.nix"
  "openssh.nix"
  "shell.nix"
  "sops.nix"
  "tmpfiles.nix"
  "users.nix"
]
