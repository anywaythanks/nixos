{ pkgs, ... }: {
  home.packages = with pkgs; [
    xclip # For X11 clipboard support
  ];

  # xdg.configFile."nvim/init.vim".source = ./init.vim;
}
