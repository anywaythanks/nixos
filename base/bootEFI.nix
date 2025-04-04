{ config, lib, pkgs, ... }:

{
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.requestEncryptionCredentials = true;
#    services.zfs.autoSnapshot.enable = true;
#    services.zfs.autoScrub.enable = true;
}