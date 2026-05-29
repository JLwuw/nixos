---
title: Lanzaboote Secure Boot Setup
---

> Target(right): machine on which NixOS is installed
>
> Executor(left): machine where you'll run commands from

# Prerequisites

-   NixOS with UEFI boot mode
-   systemd-boot bootloader configured
-   BIOS/UEFI firmware access

# Overview

Lanzaboote is a Secure Boot tool for NixOS that integrates with sbctl to sign bootloader components.

The setup process:

1.  Install Lanzaboote and sbctl
1.  Create Secure Boot keys
1.  Enable Lanzaboote in configuration
1.  Rebuild system
1.  Enroll keys in UEFI firmware
1.  Enable Secure Boot in BIOS

# Instructions

## Keys Creation

::: {.chat-container}

::: {.message .executor}

## {.tabset}

Create an empty marker file to enable Lanzaboote for the host

### Server

```bash
touch hosts/server/lanzaboote-enabled
```

### Desktop

```bash
touch hosts/desktop/lanzaboote-enabled
```

### Laptop

```bash
touch hosts/laptop/lanzaboote-enabled
```

:::

:::

::: {.chat-container}

::: {.message .target}

Create Secure Boot Keys

```bash
sudo sbctl create-keys
```

Expected output

```bash
Creating secure boot keys...✓
Secure boot keys created!
```

:::

::: {.message .target}

Check status

```bash
sudo sbctl status
```

Expected output

```
Installed:     ✓ sbctl is installed
Setup Mode:    ✓ Disabled
Secure Boot:   ✗ Disabled
```

:::

:::

## Keys Enrollment

::: {.chat-container}

::: {.message .executor}

## {.tabset}

Rebuild System

### Server

```bash
nix run nixpkgs#nixos-rebuild \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake 'path:.#server' \
  --target-host 'root@<target_machine_IP>'
```

### Desktop

```bash
nix run nixpkgs#nixos-rebuild \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake 'path:.#desktop' \
  --target-host 'root@<target_machine_IP>'
```

### Laptop

```bash
nix run nixpkgs#nixos-rebuild \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake 'path:.#laptop' \
  --target-host 'root@<target_machine_IP>'
```

:::

::: {.message .target}

Verify Lanzaboote installation

```bash
sudo sbctl verify
```

Expected output

```
✓ /efi/EFI/Linux/nixos-generation-nixos-generation-<N>-<hash>.efi is signed
...
```

> It is expected that files starting with `kernel-` are not signed.
>
> Don't delete those files tho! You won't be able to boot again.

> `invalid pe header` errors for `.conf` and `initrd` files are normal.

<details>
<summary style="color: grey;">What gets signed?</summary>

Lanzaboote creates Unified Kernel Images (UKI) in `/efi/EFI/Linux/` as `nixos-generation-*.efi` files. These bundle the kernel, initrd, and boot parameters into a single signed executable. Configuration files and separate initrd images don't need signing.

</details>

:::

:::

::: {.chat-container}

::: {.message .target}

## {.tabset}

Clear Secure Boot Keys

### Server

1.  Reboot, spam `Del` during boot
1.  Navigate to `Security` → `Secure Boot`
1.  Set `Secure Boot Mode` to `Custom`
1.  Enter `Key Management`
1.  Select `Reset to setup mode`
1.  Confirm, confirm again

### Desktop

1.  Reboot, spam `F2` during boot
1.  Switch to `Advanced Mode` (F2)
1.  Navigate to `Boot` → `Secure Boot`
1.  Set `Secure Boot Mode` to `Custom`
1.  Enter `Key Management`
1.  Set `Factory Key Provision` to `Disabled`

    > Stop forcing the factory keys on me!
1.  Select `Reset to setup mode`
1.  Don't confirm
1.  Navigate to `Save & Exit`
1.  Select `Save & Exit Setup`
1.  Confirm

:::

:::

::: {.chat-container}

::: {.message .target}

Enroll keys

```bash
sudo sbctl enroll-keys --microsoft
```

> Includes Microsoft certificates for hardware compatibility

Expected output

```bash
Enrolling keys to EFI variables...
With vendor keys from microsoft...✓
Enrolled keys to the EFI variables!
```

:::

:::

## Secure Boot

::: { .chat-container }

::: {.message .target}

## {.tabset}

Enable Secure Boot

### Server

1.  Reboot, spam `Del` during boot
1.  Navigate to `Security` → `Secure Boot`
1.  Set `Secure Boot` to `Enabled`
1.  Hit `Esc`
1.  Navigate to `Save & Exit`
1.  Select `Save Changes and Reset`
1.  Confirm

### Desktop

1.  Reboot, spam `Del` during boot
2.  Switch to `Advanced Mode` (F2)
3.  Navigate to `Boot` → `Secure Boot`
4.  Set `Secure Boot` to `Enabled`
1.  Navigate to `Save & Exit`
1.  Select `Save & Exit Setup`
1.  Confirm

:::

::: {.message .target}

Verify Secure Boot Status

```bash
bootctl status
```

Expected output

```
Secure Boot: enabled (user)
source: /efi//EFI/Linux/nixos-generation-<N>-<hash>.efi
```

:::

::: {.message .target}

Check sbctl status

```bash
sudo sbctl status
```

Expected output

```
Installed:      ✓ Sbctl is installed
Setup Mode:     ✓ Disabled
Secure Boot:    ✓ Enabled
```

:::

:::

## TPM2 LUKS Binding

::: {.chat-container}

::: {.message .target}

Wipe TPM slot

```bash
systemd-cryptenroll /dev/disk/by-partlabel/disk-nvme0n1-luks --wipe-slot=tpm2
```

:::

::: {.message .target}

Bind LUKS decryption to TPM2 for automatic unlocking

> For more information, reference: <https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html#id-1.5.7.5>

```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7+11 /dev/disk/by-partlabel/disk-nvme0n1-luks
```

Enter your LUKS decryption password

> Make sure to enroll any other LUKS devices, e.g. `/dev/disk/by-partlabel/disk-sda-luks`

<details>
<summary style="color: grey;">PCR Specification</summary>

PCRs (Platform Configuration Registers) determine when TPM2 will unlocks the disk, it does automatically so if the measured values haven't changed.

PCR 0: Platform Firmware (UEFI/BIOS)

-   Measures: Core UEFI/BIOS code
-   Changes when: BIOS firmware updates
-   Avoids: BIOS tampering

PCR 7: Secure Boot State

-   Measures: Secure Boot enabled/disabled, enrolled keys
-   Changes when: Secure Boot settings or keys modified
-   Avoids: Secure Boot bypass attacks

PCR 11: Kernel Command Line

-   Measures: Boot parameters
-   Changes when: Kernel parameters modified
-   Avoids: Boot parameter tampering

</details>

:::

:::

# Notes

-   Keys are unique per machine
-   Lanzaboote auto-signs new generations on rebuild
-   Disabling Secure Boot in BIOS bypasses key verification
