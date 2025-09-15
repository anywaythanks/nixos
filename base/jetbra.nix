{ config, lib, pkgs, ... }:
let
  customJetbrains = import ./custom-jetbrains.nix { inherit lib pkgs; };
  username = "any";
  uid = config.users.users.${username}.uid;
  gid = config.users.users.${username}.gid;
in {
  containers.jetbrains-idea = {
    privateNetwork = true;
    hostAddress = "10.0.0.1";
    localAddress = "10.0.0.2";

    # Enable Docker access by binding the socket
    bindMounts = {
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
    };

    # Share host network for Docker (optional)
    extraFlags = [ "--network=host" ];

    config = { config, pkgs, ... }: {
      # Set environment variables at container level
      environment = {
        JAVA_HOME = "${pkgs.jdk}";
        PATH = "${pkgs.jdk}/bin:${pkgs.docker}/bin:/bin";
        DISPLAY = ":0";
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
        [ customJetbrains.idea-ultimate pkgs.docker pkgs.jdk ];

      users.users.${username} = {
        isNormalUser = true;
        uid = uid;
        gid = gid;
        extraGroups = [ "docker" ];
      };

      # Enable Docker client (daemon runs on host)
      virtualisation.docker.enable = true;
    };
  };
}
