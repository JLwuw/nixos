{
  nix.settings = {
    # @source: https://discourse.nixos.org/t/how-to-set-up-cachix-in-flake-based-nixos-config/31781
    substituters = [
      "https://cache.nixos-cuda.org"
      "https://yuuhikaze.cachix.org"
      "https://comfyui.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "yuuhikaze.cachix.org-1:AtGF4hsoNZahll0Ew3U8fH1CpzKl+OJFPM1tw9qNsYo="
      "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "user"
    ];
  };
}
