# AMD configuration with OpenCL support for hashcat
{ config, pkgs, ... }:

{
  # Basic AMD kernel module
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Graphics configuration with OpenCL support
  hardware = {
    graphics.enable = true;
    graphics.extraPackages = with pkgs; [
      amdvlk
      mesa.drivers
    ];
    
    # Enable AMD OpenCL
    amdgpu.opencl.enable = true;
    
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;

    # Bluetooth configuration
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Video driver setup
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  # Basic power management
  powerManagement.enable = true;

  # Services
  services = {
    blueman.enable = true;
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    # OpenCL and tools
    clinfo
    hashcat
    
    # GPU utilities
    radeontop
    glxinfo
    
    # System tools
    mesa-demos
    
    # Bluetooth
    bluez
    blueman
  ];
}

