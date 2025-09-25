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
# Подгружает vm параметры  с указанием папки малваря и конфеги для него же
# Создает изолированный контейнер с private сетью
# По nat соединяет её с хостовой сетью
# Фильтрует сеть по белому списку ip. 

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
  idea-ultimate = pkgs.jetbrains.idea-ultimate.overrideAttrs (oldAttrs: rec {
    version = "2024.3.5";
    src = pkgs.fetchurl {
      url = "https://download-cf.jetbrains.com/idea/ideaIU-${version}.tar.gz";
      sha256 =
        "f8e8e864f4fedddf1d366a7db23fc4132192c3a6029c614a382186ff564a78a1";
    };
  });
  vmoptionsFile = pkgs.writeTextFile {
    name = "idea-vmoptions";
    text = ''
      ${(builtins.readFile ./ideas/idea.vmoptions)}


      -javaagent:/home/${username}/.config/JetBrains/activator/ja-netfilter/ja-netfilter.jar'';
  };
  dnsConfig = pkgs.writeTextFile {
    name = "dns-conf";
    text = ''
      [DNS]
      EQUAL,jetbrains.com
      EQUAL,plugin.obroom.com'';
  };
  powerConfig = pkgs.writeTextFile {
    name = "power-conf";
    text = ''
      [Result]
      EQUAL,573073346913444247214561407142509894498987155245664101041919179284681078494312973021423407800628747865997955409216990555195768784495131157470532183536330678334352936970259872292383664371023766635461208670640640397713598796754527308443528945369238828936392435144204906179485505912234011186848267709863209306511778556602033378741014496774230450197941410964251072770046033823689108688021011788376657261658186991260981140179549747190485416816818857541343311756397052162553275065673756433497298658843549248350947556567253497606120018969617499401718474045010810252766517316233217506698669999550994169132825868063129767459240617636456380105125832457025953559072498586488545368689463664536776528482569330992918118116296978450478824506118051295811556611563749715541544352883542347672927738435665998124463006449302086780325063230798474183933111892232359836665701917356724922196989335394770785847977243460626963126701415254340690317303404859918741120678339632300929493833401380690315658388765030308465421934758440592905340734684624813717040060510091600389136854092807260023999857660369404727932743646446290679772701091964625037297022489948122376995656706982039146680804056987817241335956702490931084220597158216676079818240599169758982861077029,65537,860106576952879101192782278876319243486072481962999610484027161162448933268423045647258145695082284265933019120714643752088997312766689988016808929265129401027490891810902278465065056686129972085119605237470899952751915070244375173428976413406363879128531449407795115913715863867259163957682164040613505040314747660800424242248055421184038777878268502955477482203711835548014501087778959157112423823275878824729132393281517778742463067583320091009916141454657614089600126948087954465055321987012989937065785013284988096504657892738536613208311013047138019418152103262155848541574327484510025594166239784429845180875774012229784878903603491426732347994359380330103328705981064044872334790365894924494923595382470094461546336020961505275530597716457288511366082299255537762891238136381924520749228412559219346777184174219999640906007205260040707839706131662149325151230558316068068139406816080119906833578907759960298749494098180107991752250725928647349597506532778539709852254478061194098069801549845163358315116260915270480057699929968468068015735162890213859113563672040630687357054902747438421559817252127187138838514773245413540030800888215961904267348727206110582505606182944023582459006406137831940959195566364811905585377246353->31872219281407242025505148642475109331663948030010491344733687844358944945421064967310388547820970408352359213697487269225694990179009814674781374751323403257628081559561462351695605167675284372388551941279783515209238245831229026662363729380633136520288327292047232179909791526492877475417113579821717193807584807644097527647305469671333646868883650312280989663788656507661713409911267085806708237966730821529702498972114194166091819277582149433578383639532136271637219758962252614390071122773223025154710411681628917523557526099053858210363406122853294409830276270946292893988830514538950951686480580886602618927728470029090747400687617046511462665469446846624685614084264191213318074804549715573780408305977947238915527798680393538207482620648181504876534152430149355791756374642327623133843473947861771150672096834149014464956451480803326284417202116346454345929350148770746553056995922154382822307758515805142704373984019252210715650875853634697920708113806880196144197384637328982263167395073688501517286678083973976140696077590122053014085412828620051470085033364773099146103525313018873319293728800442101520384088109603555959893639842091339193936960612783939746591187067523104203432717047111520366165309368303235547798328
    '';
  };
  urlConfig = pkgs.writeTextFile {
    name = "url-conf";
    text = ''
      [URL]
      PREFIX,https://check-license.squaretest.com
      PREFIX,https://account.jetbrains.com/lservice/rpc/validateKey.action
      PREFIX,https://account.jetbrains.com.cn/lservice/rpc/validateKey.action
      PREFIX,https://account.jetbrains.com/lservice/rpc/validateLicense.action
      PREFIX,https://account.jetbrains.com.cn/lservice/rpc/validateLicense.action
      KEYWORD,116.62.33.138
    '';
  };
  containerInterface = "ve-jetbrainocPX";
  hostInterface = "enp3s0";
  allowedIp = [ "8.8.8.8" "1.1.1.1" ];
in {
  networking.nat = {
    enable = true;
    internalInterfaces = [ containerInterface ];
    externalInterface = hostInterface;
    enableIPv6 = true;
  };

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain container_whitelist {
          # Allow established connections
          ct state established,related accept
          
          # Allow DNS
          udp dport 53 accept
          tcp dport 53 accept
          
          # Whitelisted IPs
          ip daddr {${
            lib.fold (acc: x: acc + " , " + x) (lib.head allowedIp)
            (lib.tail allowedIp)
          } } accept
          
          # Log and drop everything else
          log prefix "CONTAINER_BLOCKED: " drop
        }
        
        chain forward {
          type filter hook forward priority 0;
          ip saddr ${config.ideNetwork} jump container_whitelist
        }
      }
    '';
  };

  containers.jetbrains-idea = {
    privateNetwork = true;
    hostAddress = "10.0.0.1";
    localAddress = config.ideNetwork;
    autoStart = true;

    bindMounts = {
      "/home/${username}/.config/JetBrains/activator" = {
        hostPath = "${jaNetfilter}";
        isReadOnly = false;
      };
      "/home/${username}/.config/JetBrains/activator/ja-netfilter/config/dns.conf" =
        {
          hostPath = "${dnsConfig}";
          isReadOnly = true;
        };
      "/home/${username}/.config/JetBrains/activator/ja-netfilter/config/power.conf" =
        {
          hostPath = "${powerConfig}";
          isReadOnly = true;
        };
      "/home/${username}/.config/JetBrains/activator/ja-netfilter/config/url.conf" =
        {
          hostPath = "${urlConfig}";
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

      "/home/${username}/IdeaProjects" = {
        hostPath = "/home/${username}/Programming/IdeaProjects";
        isReadOnly = false;
      };

      "/home/${username}/.Xauthority" = {
        hostPath = "/home/${username}/.Xauthority";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      networking.nameservers = [ "8.8.8.8" ];
      services.resolved.enable = false;
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

      environment.systemPackages = (with pkgs; [
        docker
        jdk
        (jdk8.overrideAttrs (oldAttrs: { meta.priority = 10; }))
        (jdk17.overrideAttrs (oldAttrs: { meta.priority = 10; }))
        (jdk21.overrideAttrs (oldAttrs: { meta.priority = 10; }))
        (jdk23.overrideAttrs (oldAttrs: { meta.priority = 10; }))
        (jdk24.overrideAttrs (oldAttrs: { meta.priority = 10; }))
        python3
        flix
      ]) ++ [ idea-ultimate ];

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
