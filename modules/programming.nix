{ pkgs, ... }: {
  home.packages = with pkgs; [
    # common
    gnumake

    # C
    gcc

    # Haskell
    cabal2nix
    ghc
    haskellPackages.cabal-install
    haskellPackages.stack
    haskellPackages.status-notifier-item

    #petuhon
    #    (python3.withPackages (ps: with ps; [ setuptools pip ]))
    #    poetry
    #    python3Packages.ipython
    #    ruff
    # Java
    jdk
    (jdk17.overrideAttrs (oldAttrs: {
      meta.priority = 10;
    }))
    (jdk8.overrideAttrs (oldAttrs: {
      meta.priority = 10;
    }))
    (jdk22.overrideAttrs (oldAttrs: {
      meta.priority = 10;
    }))
    #    maven
    # client displayManager

    dotnetCorePackages.sdk_8_0_1xx
    
    gitFull
  ];
}
