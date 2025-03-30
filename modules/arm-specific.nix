{ config, pkgs, lib, ... }:

{
  # ARM-specific bootloader settings
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  
  # ARM-specific kernel settings
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Boot settings for ARM
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  
  # ARM-compatible graphics (minimal)
  hardware.graphics = {
    enable = true;
    extraPackages = [ ];
  };
  
  # ARM-specific video drivers
  services.xserver.videoDrivers = [ "modesetting" ];
  
  # Filesystems - use these defaults for ARM VMs
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  
  # Disable swap by default for ARM VMs
  swapDevices = [ ];
  
  # Specific ARM platform settings
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  
  # ARM-compatible networking
  networking.useDHCP = lib.mkDefault true;
  
  # ARM-compatible power management (minimal)
  powerManagement.enable = true;
  services.thermald.enable = false; # thermald doesn't work well on all ARM platforms
  
  # Disable hardware-specific services that don't work on ARM
  services.hardware.openrgb.enable = false;
  
  # ARM-specific settings for audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

