{
  inputs = {
    # Use stable packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Define unstable packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver?ref=nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    hyprland-plugins-local = {
      url = "git+file:///mnt/atlas/shisaku/hyprland-plugins?ref=feat/hyprfocus-granular-control";
      flake = false;
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-easymotion = {
      url = "github:zakk4223/hyprland-easymotion";
      inputs.hyprland.follows = "hyprland";
    };
    comfyui-nix.url = "github:utensils/comfyui-nix";
    hytale-launcher = {
      url = "github:TNAZEP/HytaleLauncherFlake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Documentation tools
    resources.url = "git+https://codeberg.org/yuuhikaze/resources";
    # Android image builder (GrapheneOS for Pixel 7)
    robotnix.url = "github:nix-community/robotnix";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, robotnix, ... }@inputs:
    let
      system = "x86_64-linux";
      # Create overlays for unstable packages and NUR
      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config = nixpkgsConfig;
          };
          n8n = final.unstable.n8n;
        })
        inputs.nur.overlays.default
      ];
      # Nixpkgs configuration
      nixpkgsConfig = {
        allowUnfreePredicate =
          pkg:
          let
            name = nixpkgs.lib.getName pkg;
          in
          # Specific Packages
          builtins.elem name [
            # Trash
            "zoom"
            # Unity
            "unityhub"
            "corefonts"
            # Blender (bc CUDA)
            "blender"
            # Osu!
            "osu-lazer-bin"
            # Firmware
            "facetimehd-calibration"
            # Mochi
            "mochi"
            # Davinci Resolve
            "davinci-resolve"
            # Google Chrome (just for dev purposes yk)
            "google-chrome"
            # Claude Code
            "claude-code"
            # n8n (sustainableUse license)
            "n8n"
            # Discord
            "discord"
            # Steam
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
            # flutter/android development
            "platform-tools"
            "tools"
            "build-tools"
            "android-sdk-platforms"
            "platforms"
            "cmake"
            "extras-google-gcm"
            "cmdline-tools"
            "ndk"
            # CUDA
            "libnvjitlink"
            "libnpp"
            "cudnn"
          ]
          # Packages that match defined prefix
          || builtins.any (prefix: nixpkgs.lib.hasPrefix prefix name) [
            # flutter/android development
            "android-sdk"
            # NVIDIA drivers
            "nvidia"
            # CUDA
            "cuda"
            "libcu"
          ]
          || builtins.any (prefix: nixpkgs.lib.hasInfix prefix name) [
            # Firmware
            "firmware"
          ];
        android_sdk.accept_license = true;
      };
      # Pixel 7 (panther) — GrapheneOS build via robotnix
      pixel7System = robotnix.lib.robotnixSystem (import ./hosts/pixel7/robotnix/configuration.nix);
    in
    {
      # Build targets for Pixel 7 GrapheneOS image
      # Usage:
      #   Generate keys (once): nix build path:.#pixel7-generateKeysScript && ./result ./keys
      #   Build & sign:         nix build path:.#pixel7-releaseScript && ./result ./keys /tmp/out
      #   Deploy OTA:           rsync /tmp/out/*.zip server:/persist/ota/
      #                         rsync /tmp/out/metadata/ server:/persist/ota/
      packages.${system} = {
        pixel7-ota = pixel7System.ota;
        pixel7-img = pixel7System.img;
        pixel7-factoryImg = pixel7System.factoryImg;
        pixel7-releaseScript = pixel7System.releaseScript;
        pixel7-generateKeysScript = pixel7System.generateKeysScript;
      };

      nixosConfigurations = {
        # Server configuration (formerly server/flake.nix#generic)
        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = nixpkgsConfig;
            }
            ./hosts/server/nixos/configuration.nix
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.home-manager.nixosModules.home-manager
            inputs.simple-nixos-mailserver.nixosModules.mailserver
          ];
          specialArgs = {
            excludedFeatures = [
              "sunshine.nix"
              "zoom.nix"
              "opencode.nix"
              "claude.nix"
              "direnv.nix"
              "appimage.nix"
              "open-llm-vtuber.nix"
              "xdg.nix"
              "obs.nix"
              "keyring.nix"
              "waydroid.nix"
              "stylix.nix"
              "hyprland.nix"
              "hyprpaper.nix"
              "ironbar.nix"
              "kitty.nix"
              "librewolf.nix"
              "mpv.nix"
              "fontconfig.nix"
              "dotfiles.nix"
              "bluetooth.nix"
              "gammastep.nix"
              "printing.nix"
              "rustup.nix"
              "power.nix"
              "litellm.nix"
              "geoclue.nix"
              "touchpad.nix"
              "nemo.nix"
              "ocr.nix"
              "keepassxc.nix"
              "foliate.nix"
              "okular.nix"
              "qimgv.nix"
              "razer.nix"
              "kdeconnect.nix"
              "steam.nix"
              "flatpak.nix"
              "ydotool.nix"
              "android.nix"
              "nvidia.nix"
              "intel.nix"
              "jupyter.nix"
              "ollama.nix"
              "comfyui.nix"
              "anki.nix"
              "monitoring.nix"
              "minecraft.nix"
            ];
          };
        };

        # Desktop configuration (formerly desktop/flake.nix#generic)
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = nixpkgsConfig;
            }
            ./hosts/desktop/nixos/configuration.nix
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            inputs.comfyui-nix.nixosModules.default
            inputs.nix-minecraft.nixosModules.minecraft-servers
          ];
          specialArgs = {
            inherit (inputs) hytale-launcher hyprland-easymotion hyprland-plugins-local nix-minecraft;
            excludedFeatures = [
              "forgejo.nix"
              "miniflux.nix"
              "acme.nix"
              "mailserver.nix"
              "invidious.nix"
              "traefik.nix"
              "lldap.nix"
              "authelia.nix"
              "opencloud.nix"
              "opencloud-audit-watcher.nix"
              "collabora.nix"
              "power.nix"
              "touchpad.nix"
              "intel-graphics.nix"
              "restic-backup.nix"
              "kener.nix"
              "ceph-radosgw.nix"
              "anki-sync-server.nix"
              "monitoring.nix"
              "n8n.nix"
              "fdroid-repo.nix"
              "ota-server.nix"
            ];
          };
        };

        # Laptop configuration
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = nixpkgsConfig;
            }
            ./hosts/laptop/nixos/configuration.nix
            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
          ];
          specialArgs = {
            inherit (inputs) hyprland-easymotion hyprland-plugins-local;
            excludedFeatures = [
              "open-llm-vtuber.nix"
              "forgejo.nix"
              "miniflux.nix"
              "acme.nix"
              "mailserver.nix"
              "invidious.nix"
              "minecraft.nix"
              "traefik.nix"
              "lldap.nix"
              "authelia.nix"
              "opencloud.nix"
              "opencloud-audit-watcher.nix"
              "collabora.nix"
              "steam.nix"
              "nvidia.nix"
              "jupyter.nix"
              "ollama.nix"
              "comfyui.nix"
              "restic-backup.nix"
              "kener.nix"
              "ceph-radosgw.nix"
              "anki-sync-server.nix"
              "monitoring.nix"
              "n8n.nix"
              "fdroid-repo.nix"
              "ota-server.nix"
            ];
          };
        };
      };

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        inputsFrom = [
          (inputs.resources.outputs.devShells.${system}.docs-converters {
            withPandoc = true;
            withStructurizr = true;
          })
          inputs.resources.outputs.devShells.${system}.docs-templates
        ];
      };
    };
}
