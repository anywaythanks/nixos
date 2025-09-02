{ pkgs, lib, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = import ./aliases.nix;
    history.extended = true;
    oh-my-zsh = {
      enable = true;
      plugins =
        [ "git" "sudo" ];#"vi-mode" "web-search" "aws" "terraform" "nomad" "vault" ];
    };
#      ${builtins.readFile ../../.secrets/env-vars.sh}
    initContent =  lib.mkOrder 550 ''
      ${builtins.readFile ./session_variables.zsh}
      ${builtins.readFile ./functions.zsh}


      bindkey -M vicmd 'k' history-beginning-search-backward
      bindkey -M vicmd 'j' history-beginning-search-forward

      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
    '';
  };
}
