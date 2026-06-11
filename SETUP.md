---
title: NixOS Initial Setup
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
| Laptop  | `F2`  |

</details>

## Laptop

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

Bootstrap the install via nixos-anywhere (sets BOOTSTRAP=1 to skip heavy services)

```bash
BOOTSTRAP=1 nix run nixpkgs#nixos-anywhere \
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

Finalize installation

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

# Post-Install

Once the system has booted, converge to the full configuration:

```bash
nixos-rebuild switch --flake 'path:.#laptop'
```

## Secrets Management

Derive Age keys from SSH and set up sops-nix:

```bash
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > /var/keys/sops-nix
```

Display public Age key for .sops.yaml config:

```bash
nix shell nixpkgs#age -c age-keygen -y /var/keys/sops-nix
```

Edit secrets:

```bash
nix run nixpkgs#sops -- secrets.yaml
```

## Secure Boot

For Secure Boot setup with Lanzaboote and sbctl, see the [Secure Boot guide](docs/secure-boot.md).

# Maintenance

## Updating

```bash
nix flake update
sudo nixos-rebuild switch --flake 'path:.#laptop'
```

## Garbage Collection

```bash
sudo nix-collect-garbage
nix-collect-garbage -d
nix store optimise
```
