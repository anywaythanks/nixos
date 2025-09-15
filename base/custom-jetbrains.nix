{ lib, pkgs }:
let
  jb-products = {
    idea-ultimate = {
      pkg = (pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: rec {
        version = "2024.3.5";
        src = pkgs.fetchurl {
          url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
          sha256 = "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
        };
      }));
    };
    # Other products...
  };
in lib.mapAttrs (name: value: value.pkg) jb-products