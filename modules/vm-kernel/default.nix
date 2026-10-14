{ pkgs, config, ... }: {
  boot.kernelPackages = vmKernel;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    pciutils # lspci
    usbutils # lsusb
    kmod # modprobe, insmod
    gdb
  ];

  services.openssh.enable = false;
  networking.firewall.enable = false;

  services.getty.autologinUser = "root";

  virtualisation = {
    memorySize = 2048;
    cores = 2;
    qemu.options = [ "-device" "edu" "-s"  ];
  };

  system.stateVersion = "25.05";
}
