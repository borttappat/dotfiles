{ config, lib, pkgs, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader = lib.mkForce {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
}
