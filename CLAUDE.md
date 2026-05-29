OVERVIEW
========

Home NixOS infrastructure with flake-based configuration for server, desktop,
and laptop hosts. Features secure boot, mesh VPN, and dendritic
module pattern where each feature module is self-contained.

PERSONIFICATION
===============

You are a NixOS systems engineer focused on declarative infrastructure. You
value modularity, reproducibility, production-grade solutions, the principle
of least privilege, DRY.

AI ASSISTANT GUIDELINES
=======================

CRITICAL
--------

- Never hardcode secrets, use SOPS
- Never edit SOPS vault (see Secrets Management section below)
- Deploy changes for the hosts as follows. ask for approval
  server: rebuild 10.100.0.1
  desktop: rebuild 10.100.0.2
  laptop: rebuild 10.100.0.3
- Use path:. prefix in flake references (includes untracked files like facter.json)
- Don't commit facter.json
- Don't modify .gitignore

PROJECT
=======

Architecture
------------

Server (10.100.0.1):
- Runs OpenWrt VM (192.168.100.1) as network gateway (DHCP, routing, firewall) YET TO DEPLOY
- Traefik as reverse proxy
- ACME for TLS certs
- WireGuard VPN
- Ceph single-node cluster (MON/MGR/OSD) for shared RBD storage
- Incus cluster leader for VMs (OpenWrt, Windows 10 LTSC)
- OpenCloud file sharing with LDAP authentication
- Observability: Grafana Alloy agent (node metrics + journald → K8s monitoring stack)
- Private F-Droid repo (fdroidserver, nginx at fdroid.yhkze.net)
- GrapheneOS OTA server (nginx at ota.yhkze.net)

Desktop (10.100.0.2):
- Hyprland compositor, Stylix theming
- GPU workstation
- Incus cluster member, Ceph RBD client

Laptop (10.100.0.3):
- Hyprland compositor, Stylix theming
- Battery management, larger swap for suspend
- Incus cluster member, Ceph RBD client

Pixel 7 (panther):
- GrapheneOS built with robotnix (hosts/pixel7/robotnix/configuration.nix)
- F-Droid with privileged extension, private repo at fdroid.yhkze.net
- SeedVault backup to OpenCloud WebDAV
- OTA updates from ota.yhkze.net
- Syncthing peer (hub-spoke with server)
- Guide: docs-src/phone/pixel7-setup.md


Incus Cluster:
- All hosts joined via WireGuard VPN (10.100.0.0/24)
- Storage pools: local (btrfs, offline-capable), shared (Ceph RBD, migration)
- CPU baseline: --target=@migratable for portable VMs, --target=<host> for native
- Live migration blocked by QEMU 10 bug, cold migration works
- Reference: modules/features/incus.nix, modules/features/ceph.nix
- Guide: docs-src/server/incus-cluster.md

WireGuard VPN (network: 10.100.0.0/24):
- Server (10.100.0.1) listens on 51820/udp, acts as hub
- Desktop (10.100.0.2) and Laptop (10.100.0.3) connect to yhkze.net:51820
- Peer-to-peer topology for lowest latency
- Reference: modules/features/wireguard.nix

Repository Structure
--------------------

flake.nix                       # Host definitions: server, desktop, laptop
hosts/{host}/nixos/             # Host entry point, packages, disko
hosts/{host}/secrets/           # SOPS-encrypted secrets (YAML + age)
modules/features/               # Auto-imported feature modules
modules/features/default.nix    # Auto-import logic, excludedModules list
values/network-details.nix      # Centralized network config (pubkeys, nodeIDs)
docs-src/                       # Documentation source (markdown)
scripts/                        # Nushell scripts (see Scripts section below)

DESIGN DECISIONS
================

Dendritic Module Pattern
------------------------

Feature modules in modules/features/ are auto-imported via default.nix. Each module
contains service config, firewall rules (nftables), persistence, SOPS secrets, or home-manager
config

Module applicability controlled via flake.nix EXCLUSION LISTS on flake.nix!
i.e. modules themselves musn't discriminate what host can use them

Home-manager config in modules goes under: home-manager.users.user = { ... };
Host-specific packages go in: hosts/{host}/nixos/packages.nix

Reference: flake.nix for excludedFeatures lists per host
Reference: modules/features/default.nix for auto-import logic

Never use lib.mkIf to check persistence enable state (causes infinite recursion).

Secrets Management
------------------

All secrets managed via SOPS-nix, encrypted with age keys.

Location: hosts/{host}/secrets/secrets.yaml

Declare secrets in modules:
sops.secrets."path/to/secret" = {
  restartUnits = [ "service.service" ];  # Auto-restart on secret change
};
Access at runtime: config.sops.secrets."path/to/secret".path

- NEVER view or decrypt secrets files
- NEVER generate secrets
- Use placeholders (e.g., PLACEHOLDER) in Nix files where hashed secrets needed.
- Provide clear instructions for user to generate, encrypt, and hash secrets
  For SOPS use the following template (on chat) ↓
  example-service:
    # openssl rand -base64 32
    secret-name:

Secure Boot
-----------

Lanzaboote + sbctl for UEFI Secure Boot.
Keys stored in /persist/secureboot.
Reference: modules/features/lanzaboote.nix

Dotfiles
--------

Hybrid approach:
- Native Nix for programs with good home-manager support (hyprland, waybar, git)
- Out-of-store symlinks for programs with their own DSL (nvim, lf)

Dotfiles location: /persist/home/user/dotfiles (git repository)
Symlinks created via config.lib.file.mkOutOfStoreSymlink
Reference: modules/features/dotfiles.nix

Theming
-------

Stylix sets custom color scheme (Workstation-only)
Reference: modules/features/stylix.nix

Reverse Proxy (Traefik)
-----------------------

Traefik handles all external HTTPS traffic and routes to services.

Certificate management: NixOS ACME with wildcard certs
- Single *.yhkze.net wildcard certificate (DNS-01 challenge via Cloudflare)
- Traefik reads certs from /var/lib/acme/yhkze.net/
- Mail server has separate mail.yhkze.net cert (different use case)
- ACME configuration in modules/features/acme.nix
- Cloudflare API token in SOPS secrets

Routing:
- HTTP (port 80) → automatic redirect to HTTPS (port 443)
- inv.yhkze.net → Invidious (TLS termination, HTTP backend)
- mc.yhkze.net → Minecraft (TLS passthrough) YET TO DEPLOY
- cloud.yhkze.net → OpenCloud (TLS termination, with OIDC auth)
- auth.yhkze.net → Authelia SSO portal
- ldap.yhkze.net → LLDAP web UI (protected by Authelia forward auth)
- office.yhkze.net → Collabora Online
- grafana.yhkze.net → Grafana (K8s pod, Authelia forward auth via authelia@file)
- alertmanager.yhkze.net → Alertmanager (K8s pod, Authelia forward auth via authelia@file)
- Dashboard on :8080 (http://localhost:8080/api/overview)

K8s Ingress: host Traefik reads IngressRoute CRDs via kubernetesCRD provider (allowCrossNamespace=false).
Cross-provider middleware refs use name@file syntax (e.g. authelia@file) — no K8s Middleware CRD needed.

Reference: modules/features/traefik.nix, modules/features/acme.nix

Mailserver
----------

Full-featured email server using simple-nixos-mailserver.

Services:
- Postfix (SMTP/submission)
- Dovecot (IMAP/POP3)
- OpenDKIM (DKIM signing)
- SPF, DMARC configuration

Certificate: mail.yhkze.net (separate from wildcard cert)
- Managed via NixOS ACME
- Used by both Postfix and Dovecot

Configuration:
- Domain: yhkze.net
- Virtual mailboxes and aliases configured declaratively
- Persistent mail storage in /persist
- Reference: modules/features/mailserver.nix

Authentication (Authelia)
-------------------------

Single sign-on (SSO) and authentication portal using Authelia.

Features:
- Multi-factor authentication (TOTP, Duo, WebAuthn)
- OIDC provider for applications (OpenCloud)
- Session management and remember-me functionality
- User database backed by LLDAP

URL: auth.yhkze.net

Configuration:
- Storage backend: SQLite (persistent)
- TOTP window: 1 minute
- Session expiry: configurable per application
- CORS support for OIDC flows
- Reference: modules/features/authelia.nix

Security:
- Forward auth middleware used by protected services (LLDAP)
- Token-based session management
- TLS required for all authentication flows

LDAP Directory (LLDAP)
----------------------
Lightweight LDAP directory service for centralized user management.

Features:
- User accounts and group management
- Web UI for administration
- Standards-compliant LDAP interface
- Backend for Authelia authentication

URL: ldap.yhkze.net (web UI, protected by Authelia)
LDAP port: 389 (local network only)

Configuration:
- Database: SQLite (persistent)
- Admin user: configured via module
- User and group creation declarative
- Reference: modules/features/lldap.nix

Integration:
- Authelia uses LLDAP as user database
- OpenCloud uses LDAP for user provisioning
- Supports LDAP-compatible applications

Scripts
-------

Scripts live in scripts/ and are written in Nushell (.nu extension).

Required header comment specifying which modules reference it:
# @reference: modules/features/...

Invoke from NixOS modules using relative path:
ExecStart = "${pkgs.nushell}/bin/nu ${../../scripts/script-name.nu}";
