{ config, lib, pkgs, ... }:

{
  # Don't import /etc/nixos/hardware-configuration.nix at build time
  # It will be generated inside the VM on first boot
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "virtio_balloon" "virtio_blk" "virtio_pci" "virtio_ring"
    "virtio_net" "virtio_scsi" "virtio_console" "ahci" "xhci_pci"
    "sd_mod" "sr_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Default filesystem config for VMs
  # This gets used during initial build, then overridden by auto-generated config on first boot
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";  # Standard qcow format default
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Legacy BIOS boot - standard for QEMU VMs
  boot.loader.grub = {
    enable = lib.mkDefault true;
    device = lib.mkDefault "/dev/vda";
    efiSupport = lib.mkDefault false;
    useOSProber = lib.mkDefault false;
  };

  # Disable systemd-boot for VMs (prefer GRUB)
  boot.loader.systemd-boot.enable = lib.mkDefault false;
}
