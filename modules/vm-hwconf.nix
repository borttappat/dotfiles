{ config, lib, pkgs, ... }:

{
imports = lib.optionals (builtins.pathExists /etc/nixos/hardware-configuration.nix) 
[ /etc/nixos/hardware-configuration.nix ];

# VM-friendly boot configuration
boot.loader = {
grub = {
enable = true;
device = "nodev";
efiSupport = true;
useOSProber = false;  # Usually not needed in VMs
};
efi = {
canTouchEfiVariables = true;
efiSysMountPoint = "/boot";
};
};

# Basic VM hardware assumptions
boot.initrd.availableKernelModules = [ 
"ata_piix" "virtio_pci" "virtio_blk" "virtio_scsi" "sd_mod" "sr_mod" 
];
boot.kernelModules = [ "kvm-intel" ];

# Enable QEMU guest agent (correct syntax)
services.qemuGuest.enable = true;
}
