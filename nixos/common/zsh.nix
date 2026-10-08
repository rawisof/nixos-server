{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons=auto";
      tree = "eza --tree --icons=auto";
    };

    promptInit = ''
      PROMPT=$'%F{red}[%n@%m:%~]$%f  '
    '';

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    interactiveShellInit = ''
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
    '';
  };
}
