# modules/arm.nix
{ config, lib, pkgs, ... }:

{
  # ARM-specific hardware settings
  hardware = {
    # Explicitly disable x86-specific features
    cpu.intel.updateMicrocode = lib.mkForce false;
    cpu.amd.updateMicrocode = lib.mkForce false;
    nvidia.enable = lib.mkForce false;
    
    # Enable firmware that might be needed
    enableRedistributableFirmware = true;
  };

  # ARM-compatible graphics
  services.xserver.videoDrivers = [ "modesetting" ];
  
  # Virtualization settings for ARM VMs
  virtualisation = {
    qemu.guestAgent.enable = true;
  };
  
  # ARM-specific boot modules
  boot.initrd.availableKernelModules = [ 
    "virtio_pci" 
    "virtio_blk" 
    "virtio_scsi" 
    "virtio_net" 
    "virtio_input"  # Important for keyboard input in VMs
  ];
  
  # ARM-specific kernel parameters (if needed)
  boot.kernelParams = [];
  
  # ARM-specific power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
  
  # Disable x86-specific services
  services.thermald.enable = lib.mkForce false;
}
