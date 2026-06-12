# @dependencies: shell.nix (provides programs.nushell.enable for yazi nushell integration)
{
  ...
}:
{
  home-manager.users.user = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableNushellIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
        };
      };
    };
  };
}
