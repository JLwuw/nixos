# NixOS

This is a NixOS flake configuration for a laptop. Everything from the boot
chain to the window manager is described declaratively in this repository.

## Design

- **Dendritic modules.** Each feature lives in a single file under
  `modules/features/`, bundling its service config, packages, firewall rules,
  and home-manager fragments. Host applicability is controlled through an
  inclusion list in `flake.nix`.
- **Secure Boot.** Lanzaboote and `sbctl` provide a verified boot chain.
- **SOPS-nix.** Secrets are age-encrypted in `secrets.yaml`, decrypted at
  activation time.

## Repository Layout

```
flake.nix              host definitions and feature-inclusion lists
hosts/laptop/          entry point, packages, disko config, encrypted secrets
modules/features/      auto-imported, self-contained feature modules
values/                shared package sets, central network details
scripts/               Nushell ops scripts (rebuild, ...)
```

## Deploying

See [SETUP.md](SETUP.md) for the initial install walkthrough.

Once the host is up, day-to-day rebuilds go through the `rebuild` script:

```bash
rebuild            # rebuild the current host
rebuild push <ip>  # build locally and push the closure over SSH
```
