{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  programs.nixvim.config = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    opts = {
      number = true;
      # relativenumber = true;
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
        settings.colorscheme = "darculaOriginal";
      };
      vimtex = {
        enable = true;
        settings = {
          view_method = "zathura";
          quickfix_mode = 1;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins;
      [
        (pkgs.vimUtils.buildVimPlugin {
          name = "darcula";
          src = pkgs.fetchFromGitHub {
            owner = "doums";
            repo = "darcula";
            rev = "master";
            sha256 = "0pwq4lb6q1a25vmlimaxcfxjh10qfvc7wdqqskyqlj1iasdaazqs";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "ale";
          src = pkgs.fetchFromGitHub {
            owner = "dense-analysis";
            repo = "ale";
            rev = "1c91102112ac5addbdbf178268c61a2ead64fb2a";
            sha256 = "06nbwzjr85vxly8xanm96k9fims29ybxydzw4jywqx9awz18cfch";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "delimitMate";
          src = pkgs.fetchFromGitHub {
            owner = "Raimondi";
            repo = "delimitMate";
            rev = "fe1983cfa1cf0924ac9b2b8576255daffd36afbf";
            sha256 = "0p7w21hja1a87mic5z488q6bzafx89h54faj7zznb8bfam8h4qpc";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "nerdtree";
          src = pkgs.fetchFromGitHub {
            owner = "preservim";
            repo = "nerdtree";
            rev = "9b465acb2745beb988eff3c1e4aa75f349738230";
            sha256 = "1j9b7f1b1pdb2v7z0b4mnfvcir4z1ycs3l2xh4rvrl7gzhlc56y5";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "vim-latex-live-preview";
          src = pkgs.fetchFromGitHub {
            owner = "xuhdev";
            repo = "vim-latex-live-preview";
            rev = "db6d40854ee5f63b25620dadd84a7ecd76d578eb";
            sha256 = "0a4669fmwacccb6159fnid01p7a3978jfdbw6mabgby15z9l24lc";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "vim-snippets";
          src = pkgs.fetchFromGitHub {
            owner = "honza";
            repo = "vim-snippets";
            rev = "4ed409154bcaa32fba6fd153cc0c915e44982872";
            sha256 = "0p998hjh9i92qyi0qaqll5qanqskpvl6ypm2hw6b16mxvvfwmv1v";
          };
        })
      ];

    extraConfigLua = ''
      vim.g.UltiSnipsExpandTrigger = '<tab>'
      vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
      vim.g.UltiSnipsJumpBackwardTrigger = '<s-tab>'
      vim.g.UltiSnipsSnippetDirectories = {"~/.config/nvim/UltiSnips"}
      vim.cmd([[colorscheme darcula]])
    '';

    # extraConfig = ''
    #   let g:tex_flavor = 'latex'
    #   let g:tex_conceal='abdmgs'
    #   autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"
    # '';
  };

  home.packages = with pkgs; [
    zathura
    xclip
    python3
    python3Packages.sympy
    texliveFull
  ];

  xdg.configFile."nvim/UltiSnips".source = ./config/UltiSnips;
}
