---
title: Secure Boot
---

# Prerequisites

Ensure the following are in place before starting:

- System is installed and can boot into NixOS
- You have root access to the machine

# Setup

Create the Lanzaboote marker file to enable secure boot support:

```bash
touch hosts/laptop/lanzaboote-enabled
```

Run the initial enrollment:

```bash
sbctl enroll-keys --microsoft
```

Rebuild the system:

```bash
nixos-rebuild switch --flake 'path:.#laptop'
```

Sign any unsigned EFI binaries:

```bash
sbctl sign-all
```

Reboot and verify Secure Boot is active:

```bash
bootctl status
```
