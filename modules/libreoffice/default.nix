{ pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice-qt
    hunspellDicts.ru_RU
  ];
}
