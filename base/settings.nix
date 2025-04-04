{ config, lib, pkgs, ... }:
{
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "cyr-sun16";
    #      keyMap = "us";
    useXkbConfig = true;
  };

  #wrapped dlaunch ~
  programs.dconf.enable = true;

  services.xserver = {
    enable = true;
    #hotkeys swap layout
    xkb = {
      layout = "us, ru";
      options = "grp:caps_toggle";
    };

    #Хрень для ускорения повторений при долгом нажатии
    autoRepeatDelay = 250;
    autoRepeatInterval = 35;
    #мб нинужна
    # displayManager.setupCommands = ''
    #   ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-0 --mode 1280x1024
    # '';
    #DM SETTING
    desktopManager.session = [{
      name = "home-manager";
      start = ''
        ${pkgs.runtimeShell} $HOME/.hm-xsession &
        waitPID=$!
      '';
    }];
    #ускорениее
    config = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "intel"
        Option "TripleBuffer" "true"
        Option "TearFree" "true"
      EndSection
    '';
    exportConfiguration = true;
  };
  #автомонтирование
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.openvpn.servers = {
    workVPN = {
      config = '' 
        config /home/any/vpns/profile-work.ovpn
        auth-user-pass /home/any/vpns/work.cred
        '';
      autoStart = true;
      updateResolvConf = true;
    };
  };
  # вмка
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # users.extraGroups.vboxusers.members = [ "any" ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  #драйвера
  hardware = {
    opengl = {
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
    pulseaudio.enable = true;
  };

  #Тырнет
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  networking = {
    hostName = "ZFS-Nixos";
    hostId = "a1c30cfd";
  };
}
