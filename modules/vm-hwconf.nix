{ config, lib, pkgs, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  boot.loader = lib.mkForce {
    grub = {
      enable = true;
      device = "/dev/sda";
      efiSupport = false;
      useOSProber = false;
    };
  };
}
