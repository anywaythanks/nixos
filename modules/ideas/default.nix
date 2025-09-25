{ lib, pkgs, ... }:
let
  jb-products = {
    idea-ultimate = {
      short-name = "idea";
      pkg = (pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: rec {
        version = "2024.3.5";
        src = pkgs.fetchurl {
          url =
            "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
          sha256 =
            "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
        };
      }));
      vmoptions = builtins.readFile ./idea.vmoptions;
    };

    webstorm = {
      short-name = "webide";
      pkg = (pkgs.jetbrains.webstorm.overrideAttrs (oldAttrs: rec {
        version = "2024.3.5";
        src = pkgs.fetchurl {
          url =
            "https://download-cf.jetbrains.com/webstorm/WebStorm-${version}.tar.gz";
          sha256 =
            "da587d7ca3ebb08f067143e4a6b35f1aa133aa10af7fc365496838006fcd1aed";
        };
      }));
      vmoptions = builtins.readFile ./webstorm.vmoptions;
    };
  };

  wrappedJBProducts = lib.mapAttrs (name: value:
    let
      vmoptionsFile = pkgs.writeTextFile { 
        name = name;
        text = value.vmoptions;
      };
    in pkgs.runCommand "${name}-wrapped" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      makeWrapper ${value.pkg}/bin/${name} $out/bin/${name} \
        --set ${lib.toUpper value.short-name}_VM_OPTIONS "${vmoptionsFile}" \
        --set JAVA_HOME "${pkgs.jdk}" \
        --set PATH "${lib.makeBinPath [ pkgs.jdk pkgs.docker ]}:$PATH"

      # Copy desktop files if they exist
      if [ -d "${value.pkg}/share" ]; then
        mkdir -p $out/share
        cp -r ${value.pkg}/share/* $out/share/
      fi
    '') jb-products;
   #keys = "https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i/";
in { 
  home.packages = lib.attrValues wrappedJBProducts;

 }
