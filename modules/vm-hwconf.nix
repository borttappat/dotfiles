{ config, lib, pkgs, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader = lib.mkForce {
    grub = {
      enable = true;
      device = "/dev/vda";  # or /dev/sda depending on your VM
      efiSupport = false;
      useOSProber = false;
    };
  };
}
