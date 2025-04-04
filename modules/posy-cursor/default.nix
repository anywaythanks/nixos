{ pkgs, ... }: {
  home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        name = "PosysCursor";
        package = pkgs.stdenvNoCC.mkDerivation {
          name = "posy-improved-cursor";

          src = pkgs.fetchFromGitHub {
            owner = "simtrami";
            repo = "posy-improved-cursor-linux";
            rev = "bd2bac08bf01e25846a6643dd30e2acffa9517d4";
            hash = "sha256-ndxz0KEU18ZKbPK2vTtEWUkOB/KqA362ipJMjVEgzYQ=";
          };

          dontBuild = true;

          installPhase = ''
            mkdir -p $out/share/icons
            mv Posy_Cursor "$out/share/icons/PosysCursor"
          '';
        };
        size = 16;

  };
}