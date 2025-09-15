#https://msucharski.eu/posts/application-isolation-nixos-containers/

{ config, lib, pkgs, ... }:
let
  customJetbrains = import ./custom-jetbrains.nix { inherit lib pkgs; };
  username = "any";
  group = config.users.users.${username}.group;
  uid = config.users.users.${username}.uid;
  gid = config.users.groups.${group}.gid;
in {
  containers.jetbrains-idea = {
    privateNetwork = true;
    hostAddress = "10.0.0.1";
    localAddress = config.ideNetwork;

    # Enable Docker access by binding the socket
    bindMounts = {
      "/dev/dri"= {
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
      # For X11 GUI applications
      "/tmp/.X11-unix" = {
        hostPath = "/tmp/.X11-unix";
        isReadOnly = true;
      };
      # Home directory access (optional, for project files)
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
      # Set environment variables at container level
      environment.variables = {
        JAVA_HOME = "${pkgs.jdk}";
        PATH = "${pkgs.jdk}/bin:${pkgs.docker}/bin:/bin";
        DISPLAY = ":0";
        XAUTHORITY = "/home/${username}/.Xauthority";
      };
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-compute-runtime
            intel-media-driver # LIBVA_DRIVER_NAME=iHD
            vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
            #vaapiVdpau
            #libvdpau-va-gl
          ];
          # driSupport = true;
        };
      };
      # Block specific domains using iptables
      networking.firewall.extraCommands = ''
        iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
        iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP
        ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
        ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP
      '';

      # Install necessary packages
      environment.systemPackages =
        [ customJetbrains.idea-ultimate pkgs.docker pkgs.jdk pkgs.xorg.xauth ];

      users.users.${username} = {
        isNormalUser = true;
        uid = uid;
        group = group;
        extraGroups = [ "docker" ];
      };
      
      users.groups.${group} = {
        gid = gid;
      };
      # Enable Docker client (daemon runs on host)
      virtualisation.docker.enable = true;
    };
  };
}
