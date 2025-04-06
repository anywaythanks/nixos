{ config, lib, pkgs, ... }:

{
  #Костыль для запуска всякого
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib # For general libs (e.g., libgcc_s)
    gcc13.cc.lib # Specific libstdc++.so.6 for Node.js 10
    # zlib
    # openssl
    # ... other dependencies
  ];
  networking.extraHosts =
    ''
      127.0.0.1 mercury
      127.0.0.1 argus
    '';
  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 80;
  };
}
