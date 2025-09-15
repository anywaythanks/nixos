{ nixvim,... }: {
  imports = [ nixvim.homeModules.nixvim ];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    options = {
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
      tabstop = 4;
      shiftwidth = 4;
      smarttab = true;
      expandtab = true;
      conceallevel = 2;
    };

    plugins = {
      lightline = {
        enable = true;
        colorscheme = "darculaOriginal";
      };
      nerdtree.enable = true; # Plug 'preservim/nerdtree'
      delimitMate.enable = true; # Plug 'Raimondi/delimitMate'
      ale.enable = true; # Plug 'dense-analysis/ale'
      vim-snippets.enable = true; # Plug 'honza/vim-snippets'
      vimtex = { # Plug 'lervag/vimtex'
        enable = true;
        settings = {
          view_method = "zathura";
          quickfix_mode = 1;
        };
      };
      vim-latex-live-preview.enable =
        true; # Plug 'xuhdev/vim-latex-live-preview'
    };

    extraConfigLua = ''
      vim.g.UltiSnipsExpandTrigger = '<tab>'
      vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
      vim.g.UltiSnipsJumpBackwardTrigger = '<s-tab>'
      vim.g.UltiSnipsSnippetDirectories = {"~/.config/nvim/UltiSnips"}
    '';

    extraConfig = ''
      let g:tex_flavor = 'latex'
      let g:tex_conceal='abdmgs'
      autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
    '';
  };
}
