{ pkgs, ... }: {
  home.packages = with pkgs; [
    xclip
    zathura
    python3
    python3Packages.sympy
    texlive.combined.scheme-full  # Полный TeX Live для работы с LaTeX
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      vim-plug
      darcula-vim
      sway-vim-syntax
      vim-devicons
      vimtex
      lightline-vim
      vim-latex-live-preview
      nerdtree
      delimitMate
      ale
      vim-snippets
      ultisnips
    ];
  };

  
  xdg.configFile."nvim".source = ./config;

}