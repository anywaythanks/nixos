{  config, lib, pkgs, ... }: 
let 
  jb-products = {
    idea = {
      pkg = (pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: rec {
        version = "2024.3.5";
        src = pkgs.fetchurl {
          url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
          sha256 = "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
        };
      }));
      vmoptions = builtins.readFile ./idea.vmoptions;
    };

    webstorm = {
      pkg = (pkgs.jetbrains.webstorm.overrideAttrs (oldAttrs: rec {
        version = "2024.3.5";
        src = pkgs.fetchurl {
          url = "https://download-cf.jetbrains.com/webstorm/WebStorm-${version}.tar.gz";
          sha256 = "da587d7ca3ebb08f067143e4a6b35f1aa133aa10af7fc365496838006fcd1aed";
        };
      }));
      vmoptions = builtins.readFile ./webstorm.vmoptions;
    };
    };

    ja-netfilter-jar = pkgs.fetchurl rec {
        version = "2022.2.0";
        url = "https://repo1.maven.org/maven2/com/ja-netfilter/ja-netfilter/${version}/ja-netfilter-${version}.jar";
        sha1 = "95cf90a51b5fe5309d7803c07c0d0ea417a9fde7";
    };

    wrappedJBProducts = lib.mapAttrs (name: value:
    let
      vmoptionsFile = pkgs.writeTextFile {
        name = "${name}-vmoptions";
        text = value.vmoptions + "\n-javaagent:${ja-netfilter-jar}=jetbrains";
      };
    in
    pkgs.runCommand "${name}-wrapped" { } ''
      mkdir -p $out/bin
      makeWrapper ${value.pkg}/bin/${name} $out/bin/${name} \
        --set ${lib.toUpper name}_VM_OPTIONS "${vmoptionsFile}" \
        --set JAVA_HOME "${pkgs.jdk}" \
        --set PATH "${lib.makeBinPath [ pkgs.jdk ]}:$PATH"
    ''
  ) jb-products;
  keys.url = "https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i/";
in {
    home.packages = lib.attrValues wrappedJBProducts;
  }
