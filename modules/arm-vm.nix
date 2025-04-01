# modules/arm-vm.nix
{ config, lib, pkgs, ... }:

{
  # Override hardware-specific settings that might conflict with ARM VM
  
  # Disable any Intel/AMD specific settings
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  hardware.cpu.amd.updateMicrocode = lib.mkForce false;
  
  # Ensure proper keyboard settings
  console.keyMap = lib.mkForce "sv-latin1";
  services.xserver.xkb = {
    layout = lib.mkForce "se";
    variant = lib.mkForce "";
  };
  
  # VM-specific settings for better performance
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  
  # Disable services that might not work in ARM VM
  services.thermald.enable = lib.mkForce false;
  services.tlp.enable = lib.mkForce false;
  services.auto-cpufreq.enable = lib.mkForce false;
  
  # Disable hardware-specific services
  services.asusd.enable = lib.mkForce false;
  hardware.openrgb.enable = lib.mkForce false;
  
  # Keep podman instead of docker for better ARM support
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    docker.enable = lib.mkForce false;
  };
  
  # Ensure proper input devices are available
  services.xserver.libinput = {
    enable = true;
    # Increase sensitivity to help with VM input
    mouse = {
      accelSpeed = "0.7";
    };
    touchpad = {
      accelSpeed = "0.7";
      disableWhileTyping = false;
    };
  };
  
  # Disable any GPU-specific configuration
  hardware.graphics = lib.mkForce {
    enable = true;
    # No specific GPU drivers for the VM
  };
  
  # Video drivers for VM
  services.xserver.videoDrivers = lib.mkForce [ "virtio" "modesetting" ];
  
  # Boot settings specific to ARM VM
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "virtio_net" ];
  boot.kernelParams = [ "console=ttyAMA0" ];
}
