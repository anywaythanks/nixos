{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    taffybar = {
      url = "github:taffybar/taffybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, taffybar, nixpkgs, home-manager }:
    let
      home-common = { lib, ... }: {
        _module.args = {
          colorscheme = import ./colorschemes/dracula.nix;
        };
        nixpkgs.config = {
          #              allowUnfreePredicate = pkg:
          #                builtins.elem (lib.getName pkg) [
          #                  "unrar"  #hook
          #                  "discord"
          #                  "corefonts-1"
          #                  "vscode"
          #                  "vscode-extension-MS-python-vscode-pylance"
          #                ];
          allowUnfree = true;
        };
        
        #nixpkgs.overlays = [ taffybar.overlays.default ];
        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
        home.stateVersion = "24.05";
        imports = [
          ./modules/bat
          ./modules/cli.nix
          ./modules/neovim/default.nix
          ./modules/fonts.nix
          ./modules/programming.nix
          ./modules/zsh
          ./modules/vscode
        ];
      };
      home-linux = {
        home.homeDirectory = "/home/any";
        home.username = "any";
        imports = [
          # ./modules/discord

          # Desktop Environment
          ./modules/desktop-environment.nix
          ./modules/betterlockscreen
          ./modules/deadd
          ./modules/eww
          ./modules/ideas
          ./modules/libreoffice
          ./modules/blender
          ./modules/syncthing
          ./modules/posy-cursor
          ./modules/direnv
          ./modules/chromium
          ./modules/gtk
          ./modules/flameshot
          ./modules/lutris
          ./modules/obs
          ./modules/picom
          ./modules/alacritty
          ./modules/plasma-browser-integration
          ./modules/rofi
          ./modules/taffybar
          ./modules/xidlehook
           # ./modules/docker
          ./modules/xmonad
        ];
      };

    in
    {
      nixosConfigurations.ZFS-Nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };

      homeConfigurations = {
        nixos = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ home-common home-linux ];
        };
      };
    };
}


#grid
