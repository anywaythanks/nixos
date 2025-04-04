{ config, pkgs, colorscheme, ... }: {
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: with haskellPackages; [ taffybar ];
      config = pkgs.writeText "xmonad.hs" ''
        ${builtins.readFile ./config.hs}
        main :: IO ()
        main = xmonad $ myConfig "${colorscheme.accent-primary}" "${colorscheme.bg-primary-bright}"
      '';
    };
  };
}
