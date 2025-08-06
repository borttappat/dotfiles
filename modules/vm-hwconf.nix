{ config, lib, pkgs, ... }:

{
imports = lib.optionals (builtins.pathExists /etc/nixos/hardware-configuration.nix) 
[ /etc/nixos/hardware-configuration.nix ];

boot.loader = {
  grub = {
    enable = true;
    device = "/dev/vda";
    efiSupport = false;
  };
  systemd-boot.enable = false;
};

boot.initrd.availableKernelModules = [ 
  "ata_piix" "virtio_pci" "virtio_blk" "virtio_scsi" "sd_mod" "sr_mod" 
];
boot.kernelModules = [ "kvm-intel" ];

services.qemuGuest.enable = true;
}
