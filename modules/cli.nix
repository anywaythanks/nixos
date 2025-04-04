{ pkgs, ... }: {
  home.packages = with pkgs; [
    #archive
    unrar
    unzip

    lsd # ls
    bat # cat
    fastfetch
    pciutils

    zoxide
  ];
}
