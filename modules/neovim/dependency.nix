{ pkgs, ...}:
{
  home.packages = with pkgs; [
    zathura
    xclip
    python3
    python3Packages.sympy
    texliveFull
  ];

  xdg.configFile."nvim/UltiSnips".source = ./config/UltiSnips;
}