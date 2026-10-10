{ config, lib, pkgs, ... }: {
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
    # Планшетик
    digimend.enable = true;
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
   
    exportConfiguration = true;
  };
  #автомонтирование
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

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

  #Музика
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true; # Нужно для 32-битных приложений и Steam
    };
    nvidia = {
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
  #драйвера
  # hardware = {
  #   # graphics = {
  #   #   enable = true;
  #   #   extraPackages = with pkgs; [
  #   #     intel-compute-runtime
  #   #     intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #   #     vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #   #     #vaapiVdpau
  #   #     #libvdpau-va-gl
  #   #   ];
  #   #   # driSupport = true;
  #   # };
  # };

  services.xserver.videoDrivers = [ "nvidia" ];

  #Тырнет
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  networking = {
    hostName = "ZFS-Nixos";
    hostId = "a1c30cfd";
  };

  fileSystems."/home/any/windows" = {
    device = "/dev/disk/by-uuid/485A83305A831A38";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "umask=0022"              # права по умолчанию: rwxr-xr-x
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=10"
    ];
  };
}
