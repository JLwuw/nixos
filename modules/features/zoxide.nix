{ ... }: {
  home-manager.users.user = {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
