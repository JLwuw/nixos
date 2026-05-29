{ pkgs, ... }:
{
  home-manager.users.user = {
    programs.bash.enable = true;
    programs.nushell = {
      enable = true;
      settings.show_banner = false;
      extraConfig = ''
        $env.config.history = {
          sync_on_enter: false
        }
      '';
    };
    home.sessionPath = [
      "$HOME/.zvm/bin"
      "$HOME/.local/bin"
    ];
    home.packages = [
      (pkgs.writeScriptBin "rebuild" (builtins.readFile ../../scripts/rebuild.nu))
    ];
    home.shellAliases = {
      # neovim
      v = "nvim";
      vim = "nvim";
      vi = "nvim";
      # fastfetch
      ff = "fastfetch";
      # opencode
      oc = "opencode";
      # difftastic
      dt = "difft --skip-unchanged";
      # tern
      nt = "nix develop path:. --command -- tern";
    };
    home.sessionVariables = {
      EDITOR = "nvim";
      QT_STYLE_OVERRIDE = "kvantum";
      SOPS_AGE_KEY_FILE = "/var/keys/sops-nix";
    };
  };
  environment.shells = with pkgs; [
    bash
    nushell
  ];
}
