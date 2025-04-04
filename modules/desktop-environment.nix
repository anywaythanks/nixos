{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Busybox replacements: As the default ones give out very
    # limited info which is extremely unhelpful when debugging
    # something
    #    less
    #    pciutils
    #    procps
    #    psmisc
    #    stress
    #    usbutils
    killall
    # Custom scripts

    # File browser
    ranger

    # Image viewer
    feh

    # Info
    #    glxinfo
    #    radeontop

    # Openvpn interop
    #    gnome3.networkmanager-openvpn gtk
    glib
    gnome.dconf-editor
    dconf
    # Screenshot utility status
    # flameshot
  
    #bittorrent
    transmission-qt
    # Sound control panel
    pavucontrol

    #vido
    vlc
    # System tray (Kind of a hack atm)
    # Need polybar to support this as a first class module
    gnome3.nautilus
    gnomeExtensions.system-monitor
    gtk3
    
    networkmanagerapplet
    nm-tray
    pasystray
    psensor
    kitty
    # Utility to open present directory (Only use it with xmonad to open
    # terminal in same directory)
    xcwd

    telegram-desktop

    keepassxc
  ];
}

