{ pkgs, ... }:

{
   imports =
    [
      ./extraPlugins.nix
      ./nixvim.nix
      ./dependency.nix
    ];
}
