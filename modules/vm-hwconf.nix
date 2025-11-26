{ config, lib, pkgs, ... }:

{
  imports = [
    # Import /etc/nixos/hardware-configuration.nix if it exists (overrides defaults below)
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix)
    /etc/nixos/hardware-configuration.nix;

  boot.initrd.availableKernelModules = [
    "virtio_balloon" "virtio_blk" "virtio_pci" "virtio_ring"
    "virtio_net" "virtio_scsi" "virtio_console" "ahci" "xhci_pci"
    "sd_mod" "sr_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Default filesystem config for VMs
  # Gets overridden by /etc/nixos/hardware-configuration.nix if it exists
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda3";  # Default for most NixOS QEMU VMs
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
