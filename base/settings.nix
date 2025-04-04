{ config, lib, pkgs, ... }:
{
  time.timeZone = "Europe/Moscow";
  networking = {
    hostName = "ZFS-Nixos";
    hostId = "a1c30cfd";
  };

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
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-0 --mode 1280x1024
    '';
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

  # вмка
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "any" ];
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
  networking.wireless.enable = true;

  
  #бдшечки
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "applec" "anyway" ];
    ensureUsers = [
      {
        name = "anyway";
      }
    ];

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     127.0.0.1/32   trust
      host  all       all     ::1/128        trust
    '';
  };
}
