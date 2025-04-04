# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  root_dot_name = /default.nix;
in
{

  imports =
    [
      ./hardware-configuration.nix
      (./base + root_dot_name)
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enabling flakes
  services.openssh.enable = true;
  system.stateVersion = "24.05"; # Don't change it bro
}

