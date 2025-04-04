{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
#    permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0"];
  };
  environment.systemPackages = with pkgs; [
      #redactor
      neovim

      #Shells
      zsh

      ripgrep # grep

      home-manager 
    ];
}