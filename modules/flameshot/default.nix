{ pkgs, ... }:
let
  flameshot-gui = pkgs.writeShellApplication
    {
      name = "flameshot-gui";
      runtimeInputs = with pkgs; [ flameshot xdotool ];
      text = builtins.readFile ./flameshot-gui.sh;
    };
  flameshot-gui-d = pkgs.writeShellApplication
    {
      name = "flameshot-gui-d";
      runtimeInputs = with pkgs; [ flameshot xdotool ];
      text = builtins.readFile ./flameshot-gui-d.sh;
    };
in
{
  # https://github.com/flameshot-org/flameshot/issues/784#issuecomment-918382722\

  home = {
    packages = [ flameshot-gui flameshot-gui-d pkgs.flameshot ];
  };
}
