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
  
  # --- KEYBOARD INPUT FIXES ---
  
  # Ensure input drivers are available
  services.xserver.libinput.enable = true;
  
  # Make sure evdev driver is included
  services.xserver.modules = [ pkgs.xorg.xf86inputevdev ];
  
  # Add explicit keyboard configuration
  services.xserver.xkbModel = "pc105";
  
  # Ensure all input devices have proper permissions
  services.udev.extraRules = ''
    # Input devices - ensure proper permissions
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
    # USB devices
    SUBSYSTEM=="usb", MODE="0660", GROUP="input"
  '';
  
  # Add input-related packages
  environment.systemPackages = with pkgs; [
    xorg.xf86inputevdev
    xorg.xf86inputlibinput
    xorg.xkbcomp
    xorg.xmodmap
    evtest  # For debugging input issues
  ];
  
  # Enable additional kernel modules that might be needed for input devices
  boot.kernelModules = [ "hid" "usbhid" ];
  
  # Set up console keyboard just in case
  console.useXkbConfig = true;
  
  # Ensure X11 is properly configured for the keyboard
  services.xserver.deviceSection = ''
    Option "AutoAddDevices" "true"
  '';
  
  # Virtual console settings that are more ARM-friendly
  console = {
    packages = with pkgs; [ terminus_font ];
    font = "ter-v18n";
    keyMap = "us";
  };
  
  # Additional X11 configuration files
  environment.etc."X11/xorg.conf.d/00-keyboard.conf".text = ''
    Section "InputClass"
      Identifier "keyboard-all"
      MatchIsKeyboard "on"
      Driver "evdev"
      Option "XkbLayout" "us"
      Option "XkbOptions" "terminate:ctrl_alt_bksp"
    EndSection
  '';
}
