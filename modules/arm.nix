{ config, pkgs, lib, ... }:

{
  # ARM-compatible packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim
    git
    curl
    wget
    htop
    zsh
    starship
    tmux
    bat
    eza
    
    # System tools
    killall
    pciutils
    usbutils
    inetutils
    file
    
    # Input device support
    xorg.xf86inputlibinput
    xorg.xf86inputevdev
    xorg.xf86inputkeyboard
    xorg.xf86inputmouse
    
    # Window manager and desktop
    i3-gaps
    i3lock-color
    feh
    rofi
    polybar
    alacritty
    
    # Development
    python3
    nodejs
    gcc
    
    # Networking
    nmap
    wireshark
    openvpn
    
    # Remove these ARM-incompatible packages:
    # rar
    # thermald
    # (and anything else that caused issues)
  ];
  
  # Specific ARM configuration
  services.xserver = {
    enable = true;
    exportConfiguration = true; # Helps with debugging

    # Input device configuration
    libinput.enable = true;
    
    # Extra modules for input devices
    modules = [ pkgs.xorg.xf86inputlibinput ];
    
    # Make sure evdev and libinput are explicitly enabled
    inputClassSections = [
      ''
        Identifier "evdev keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
      ''
      ''
        Identifier "libinput keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
      ''
    ];
  };
  
  # QEMU-specific settings for ARM VM
  services.qemuGuest.enable = true;
  
  # Ensure basic hardware support
  hardware = {
    enableRedistributableFirmware = true;
    
    # Explicitly disable these on ARM
    nvidia.enable = lib.mkForce false;
    cpu.intel.updateMicrocode = lib.mkForce false;
    cpu.amd.updateMicrocode = lib.mkForce false;
  };
  
  # Remove thermald service
  services.thermald.enable = lib.mkForce false;
  
  # Make sure necessary kernel modules are loaded
  boot.initrd.availableKernelModules = [ 
    "virtio_pci" 
    "virtio_blk" 
    "virtio_scsi" 
    "virtio_net" 
    "virtio_input"  # Important for keyboard input
  ];
  
  # VM-specific optimizations
  virtualisation = {
    # Ensure qemu-guest-agent is installed
    qemu.guestAgent.enable = true;
  };
}
