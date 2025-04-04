{ config, lib, pkgs, ... }:

{
    imports =
    [
      ./settings.nix
      ./bootEFI.nix
      ./users.nix
      ./packages.nix
    ];
}