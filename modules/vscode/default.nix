{ pkgs, ... }: {
  home = {
    file.".config/Code/User/settings.json".source = ./settings.json;
    packages = with pkgs; [
      # haskell-language-server
      nixfmt
    ];
  };
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      k--kato.intellij-idea-keybindings
      haskell.haskell
      #      sergey-kintsel.haskell-vscode-formatter
      # pets
      #      phoityne.hdx4vsc
      #      JustusAdam.language-haskell
    ];
  };
}
