{ config, lib, pkgs, ... }:

{
imports = lib.optionals (builtins.pathExists /etc/nixos/hardware-configuration.nix) 
[ /etc/nixos/hardware-configuration.nix ];

boot.loader = {
systemd-boot.enable = true;
grub.enable = false;
efi = {
canTouchEfiVariables = true;
efiSysMountPoint = "/boot/efi";
};
};

boot.initrd.availableKernelModules = [ 
"ata_piix" "virtio_pci" "virtio_blk" "virtio_scsi" "sd_mod" "sr_mod" 
];
boot.kernelModules = [ "kvm-intel" ];

services.qemuGuest.enable = true;
}
