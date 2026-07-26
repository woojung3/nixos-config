{ ... }:
{
  imports = [
    ./disk.nix
    ./hardware.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/applications.nix
  ];

  networking.hostName = "jwlaptop";

  system.stateVersion = "26.05";
}
