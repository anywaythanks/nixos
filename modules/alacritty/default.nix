{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 13.0;
        normal = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        bold = {
          family = "JetBrains Mono";
          style = "ExtraBold";
        };
      };
    };
  };
}