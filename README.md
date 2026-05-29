---
title: Common NixOS Configuration
---

> Target(right): machine on which NixOS will be installed upon
>
> Executor(left): machine where you'll run nixos-anywhere from

# Prerequisites {.tabset}

Enter BIOS and proceed as follows:

<details>
<summary style="color: grey;">Key Reference to Enter BIOS</summary>

| Machine | Key   |
|---------|-------|
| Server  | `Del` |
| Desktop | `F2` |
| Laptop  | `F2`  |

</details>

## Desktop

<span style="color:red">Disable CSM support and Secure Boot (the latter will be enabled afterwards)</span>

1.  Switch to `Advanced Mode (F2)`
1.  Navigate to `Boot`
1.  Set `CSM Support` to disabled
1.  Enter `Secure Boot`
1.  Set `Secure Boot` to disabled

Set UEFI/Administrator password

1.  Switch to `Advanced Mode (F2)`
1.  Navigate to `Boot`
1.  Set `Security Option` to `Setup`

    > So that password is only required when accessing BIOS and not at system boot
1.  Select `Administrator Password`
1.  Enter password

# Installation & Deployment

Live-boot a [minimal NixOS image](https://nixos.org/download/#minimal-iso-image) on the target machine, then configure as follows:

::: {.chat-container}

::: {.message .target}

Escalate privileges and prepare the environment

```bash
sudo -i
loadkeys es
passwd # set a temporary password for setup
systemctl start sshd
```

:::

::: {.message .target}

Generate LUKS decryption key

```bash
dd if=/dev/urandom bs=1 count=32 | base64 > /tmp/pass
```

<details>
<summary style="color: grey;">Wipe unused boot partitions if any with `efibootmgr`</summary>

List entries along with their IDs

```bash
sudo efibootmgr
```

Delete entry

```bash
sudo efibootmgr -b <ID> -B
```

</details>

:::

::: {.message .executor}

## {.tabset}

Run nixos-anywhere

### Server

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#server' \
  --phases 'kexec,disko' \
  --generate-hardware-config nixos-facter hosts/server/facter.json \
  --show-trace \
  'root@<target_machine_IP>'
```

### Desktop

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#desktop' \
  --phases 'kexec,disko' \
  --generate-hardware-config nixos-facter hosts/desktop/facter.json \
  --show-trace \
  'root@<target_machine_IP>'
```

### Laptop

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#laptop' \
  --phases 'kexec,disko' \
  --generate-hardware-config nixos-facter hosts/laptop/facter.json \
  --show-trace \
  'root@<target_machine_IP>'
```

:::

::: {.message .target}

Set up SSH hosts

```bash
mkdir -p /mnt/persist/etc/secrets/initrd
ssh-keygen -t ed25519 -f /mnt/persist/etc/secrets/initrd/ssh_host_ed25519_key -N "" -C ""
chmod 400 /mnt/persist/etc/secrets/initrd/*
```

:::

::: {.message .target}

Set Age private keys for sops-nix

```bash
mkdir -p /mnt/persist/var/keys
vim /mnt/persist/var/keys/sops-nix
```

:::

::: {.message .executor}

## {.tabset}

Finalize installation

### Server

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#server' \
  --phases 'install,reboot' \
  --show-trace \
  'root@<target_machine_IP>'
```

### Desktop

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#desktop' \
  --phases 'install,reboot' \
  --show-trace \
  'root@<target_machine_IP>'
```

### Laptop

```bash
nix run nixpkgs#nixos-anywhere \
  --extra-experimental-features 'nix-command flakes' \
  -- --flake 'path:.#laptop' \
  --phases 'install,reboot' \
  --show-trace \
  'root@<target_machine_IP>'
```

:::

::: {.message .executor}

Once system reboots, unlock LUKS disk encryption via SSH

```bash
cat <<< "<pass>" | ssh -p 2224 root@<target_machine_IP> systemd-tty-ask-password-agent
```

> This action is required on every boot until TPM2 auto-unlock is enabled

:::

:::

# Post-Install Steps

## Secure Boot

Reference [lanzaboote-setup.md](./lanzaboote-setup.md) for complete Secure Boot setup with Lanzaboote and sbctl.

# Maintenance

## Secrets Management

> For more information, watch: <https://youtube.com/watch?v=G5f6GC7SnhU>

Derive Age keys from SSH and manage secrets file

```bash
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > /var/keys/sops-nix
```

Display public Age key for .sops.yaml config

```bash
nix shell nixpkgs#age -c age-keygen -y /var/keys/sops-nix
```

Edit secrets

```bash
nix run nixpkgs#sops -- secrets.yaml
```

## System Updates

Update flake inputs

```bash
nix flake update
```

Upgrade system

```bash
sudo nixos-rebuild switch --flake 'path:.#<machine>'
```

## Garbage Collection

Delete unreferenced store paths

```bash
sudo nix-collect-garbage
```

Delete old generations

```bash
nix-collect-garbage -d
# nix-env --delete-generations 10-20
```

Optimise store (deletes duplicate files in Nix store)

```bash
nix store optimise
```

## Impermanence

When declaring a new file or directory as non-impermanent, first move it to persistent storage, then rebuild the system.

```bash
mv /path/to/persist /persist/destination/path/
```

> Where `persist` can be either a directory or file
