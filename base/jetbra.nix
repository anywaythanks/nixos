# https://msucharski.eu/posts/application-isolation-nixos-containers/
# https://gist.github.com/nort3x/dde6757cb630afe052331e04ca1ab79e
# https://gist.github.com/PathumRathnayaka/c8179784a89d4011d19099bf06813e68
# https://boommanpro.cn/post/ja-netfilter

# Ключи до 2099 года
# https://ckey.run/ 

# Быстрая активация линух
# curl -sSL ckey.run | bash 
# Винда
# irm https://ckey.run/ | iex

# source code malware
# https://github.com/neKamita/ToolBox-Activator/
# https://gitee.com/ja-netfilter/ja-netfilter/
# https://gitee.com/ja-netfilter/plugin-native
# https://gitee.com/ja-netfilter/plugin-dns
# https://gitee.com/ja-netfilter/plugin-power
# https://gitee.com/ja-netfilter/plugin-url
# https://gitee.com/ja-netfilter/plugin-hideme

# Код ниже загружает ide с модифицированной ссылки, которая все еще доступна в рф
# Загружает малварь с его плагинами и создает папку для него
# Подгружает vm параметры для каждого продукта с указанием папки малваря
# Создает изолированный контейнер с private сетью
# По nat соединяет её с хостовой сетью
# Фильтрует сеть по white list и подменяет домен плагинов, чтобы работали в рф. 

{ config, lib, pkgs, ... }:
let
  customJetbrains = import ./custom-jetbrains.nix { inherit lib pkgs; };
  username = "any";
  group = config.users.users.${username}.group;
  uid = config.users.users.${username}.uid;
  gid = config.users.groups.${group}.gid;
  jaNetfilter = pkgs.stdenv.mkDerivation {
    name = "ja-netfilter";
    src = pkgs.fetchurl {
      url =
        "https://gitee.com/ja-netfilter/ja-netfilter/releases/download/2022.2.0/ja-netfilter-2022.2.0.zip";
      sha256 = "04adqlwnfal3jiyjhgd6cp21vk0kc9w4rlm5yd8f1q3ggv2a6i4a";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out
      unzip $src -d $out
    '';
  };
  idea-ultimate = {
    pkg = (pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: rec {
      version = "2024.3.5";
      src = pkgs.fetchurl {
        url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
        sha256 =
          "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
      };
    }));
  };
  vmoptionsFile = pkgs.writeTextFile {
    text = (builtins.readFile ./ideas/idea.vmoptions)
      + "\\n\\n-javaagent:/home/${username}/.conifg/JetBrains/ja-netfilter/ja-netfilter.jar=jetbrains";
  };
in {
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-jetbrainocPX" ];
    externalInterface = "enp3s0";
    enableIPv6 = true;
  };
  containers.jetbrains-idea = {
    privateNetwork = true;
    hostAddress = "10.0.0.1";
    localAddress = config.ideNetwork;

    bindMounts = {
      "/home/${username}/.config/JetBrains" = {
        hostPath = "${jaNetfilter}";
        isReadOnly = true;
      };
      "/home/${username}/.config/JetBrains/idea.vmoptions" = {
        hostPath = "${vmoptionsFile}";
        isReadOnly = true;
      };
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
      "/var/run/docker.sock" = {
        hostPath = "/var/run/docker.sock";
        isReadOnly = false;
      };
      "/nix/store" = {
        hostPath = "/nix/store";
        isReadOnly = true;
      };
      "/tmp" = {
        hostPath = "/tmp";
        isReadOnly = false;
      };

      "/tmp/.X11-unix" = {
        hostPath = "/tmp/.X11-unix";
        isReadOnly = true;
      };

      "/home/${username}/Projects" = {
        hostPath = "/home/${username}/Projects";
        isReadOnly = false;
      };

      "/home/${username}/.Xauthority" = {
        hostPath = "/home/${username}/.Xauthority";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      networking.useHostResolvConf = lib.mkForce false;
      services.resolved.enable = true;
      environment.sessionVariables = {
        JAVA_HOME = "${pkgs.jdk}";
        PATH = "${pkgs.jdk}/bin:${pkgs.docker}/bin:/bin";
        DISPLAY = ":0";
        XAUTHORITY = "/home/${username}/.Xauthority";
        IDEA_VM_OPTIONS = "/home/${username}/.config/JetBrains/idea.vmoptions";
      };
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-compute-runtime
            intel-media-driver
            vaapiIntel
          ];
        };
      };

      networking.firewall.extraCommands = ''
        iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
        iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP
        ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
        ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP
      '';

      environment.systemPackages = with pkgs;
        [
          docker
          jdk
          (jdk17.overrideAttrs (oldAttrs: { meta.priority = 10; }))
          (jdk8.overrideAttrs (oldAttrs: { meta.priority = 10; }))
          (jdk21.overrideAttrs (oldAttrs: { meta.priority = 10; }))

          flix
        ] ++ [ idea-ultimate ];

      users.users.${username} = {
        isNormalUser = true;
        uid = uid;
        group = group;
        extraGroups = [ "docker" ];
      };

      users.groups.${group} = { gid = gid; };

      virtualisation.docker.enable = true;
    };
  };
}
