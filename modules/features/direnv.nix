{
  home-manager.users.user = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # High-performance version for Nix
    };
  };
}
