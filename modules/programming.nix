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
    python3
    # (python3.withPackages (ps: with ps; [ setuptools pip ]))
    # poetry
    # python3Packages.ipython
    # ruff
    # Java
    jdk
    (jdk17.overrideAttrs (oldAttrs: { meta.priority = 10; }))
    (jdk8.overrideAttrs (oldAttrs: { meta.priority = 10; }))
    (jdk21.overrideAttrs (oldAttrs: { meta.priority = 10; }))

    flix
    #    maven
    # client displayManager
  ];
}
