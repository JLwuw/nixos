{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    resources.url = "git+https://codeberg.org/yuuhikaze/resources";
    hyprland-plugins-local = {
      url = "github:yuuhikaze/hyprland-plugins/feat/hyprfocus-granular-control";
      flake = false;
    };
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
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      version = nixpkgs.lib.trivial.release;
      bootstrap = (builtins.getEnv "BOOTSTRAP") == "1";

      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config = nixpkgsConfig;
          };
        })
        inputs.nur.overlays.default
      ];

      nixpkgsConfig = {
        allowUnfreePredicate =
          pkg:
          let
            name = nixpkgs.lib.getName pkg;
          in
          builtins.elem name [
            "zoom"
            "unityhub"
            "corefonts"
            "blender"
            "osu-lazer-bin"
            "facetimehd-calibration"
            "mochi"
            "davinci-resolve"
            "google-chrome"
            "discord"
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
          ]
          || builtins.any (prefix: nixpkgs.lib.hasPrefix prefix name) [
            "nvidia"
            "cuda"
            "libcu"
          ]
          || builtins.any (prefix: nixpkgs.lib.hasInfix prefix name) [
            "firmware"
          ];
        android_sdk.accept_license = true;
      };

      mkSystem =
        {
          host,
          includedFeatures,
          extraModules ? [ ],
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = nixpkgsConfig;
            }
            (./hosts + "/${host}/nixos/configuration.nix")
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.home-manager.nixosModules.home-manager
          ]
          ++ extraModules;
          specialArgs = {
            inherit version bootstrap includedFeatures;
          }
          // extraSpecialArgs;
        };
    in
    {
      nixosConfigurations = {
        laptop = mkSystem {
          host = "laptop";
          extraModules = [ inputs.stylix.nixosModules.stylix ];
          includedFeatures = [
            "appimage.nix"
            "audio.nix"
            "bluetooth.nix"
            "bootloader.nix"
            "direnv.nix"
            "distrobox.nix"
            "dotfiles.nix"
            "facter.nix"
            "fail2ban.nix"
            "fastfetch.nix"
            "flatpak.nix"
            "fonts.nix"
            "gammastep.nix"
            "garbage-collector.nix"
            "geoclue.nix"
            "git.nix"
            "hardware.nix"
            "hyprland.nix"
            "hyprlock.nix"
            "ironbar.nix"
            "keepassxc.nix"
            "keyring.nix"
            "kitty.nix"
            "lanzaboote.nix"
            "locale.nix"
            "locate.nix"
            "mpv.nix"
            "nemo.nix"
            "networking.nix"
            "nix-ld.nix"
            "nix-settings.nix"
            "obs.nix"
            "ocr.nix"
            "okular.nix"
            "openssh.nix"
            "podman.nix"
            "power.nix"
            "printing.nix"
            "qimgv.nix"
            "security.nix"
            "shell.nix"
            "sops.nix"
            "starship.nix"
            "stylix.nix"
            # "syncthing.nix"
            "sysctl.nix"
            "tmpfiles.nix"
            "users.nix"
            "vicinae.nix"
            "xdg.nix"
            "yazi.nix"
            "zoxide.nix"
          ];
          extraSpecialArgs = {
            inherit (inputs) hyprland-plugins-local;
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
