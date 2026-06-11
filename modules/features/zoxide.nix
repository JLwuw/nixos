{ ... }: {
  home-manager.users.user = {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    home.persistence."/persist".directories = [
      ".local/share/zoxide" # Zoxide DB
    ];
  };
}
