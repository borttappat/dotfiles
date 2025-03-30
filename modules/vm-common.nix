{ config, pkgs, lib, ... }:

{
  # VM specific settings
  
  # Guest additions for VM environments
  virtualisation.vmware.guest.enable = lib.mkDefault false;
  virtualisation.virtualbox.guest.enable = lib.mkDefault false;
  
  # Check if we're in QEMU
  virtualisation.qemu.guest.enable = lib.mkDefault true;
  
  # SPICE agent for better integration with QEMU/KVM
  services.spice-vdagentd.enable = true;
  
  # CPU frequency should be managed by the VM
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  
  # Disable power management in VMs
  powerManagement.enable = false;
  
  # Reduce services in VM
  services.thermald.enable = false;
  services.earlyoom.enable = lib.mkDefault false;
  
  # VM networking settings
  networking = {
    useDHCP = true;
    interfaces = {};
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowPing = true;
    };
  };
  
  # Set auto-login for traum user in VM
  services.getty.autologinUser = "traum";
  
  # Graphics settings for VMs
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    windowManager.i3.enable = true;
    
    # Disable 3D acceleration in VMs
    videoDrivers = [ "modesetting" ];
    
    # Set a reasonable resolution for VM displays
    monitorSection = ''
      VendorName "Virtual Machine Monitor"
      ModelName "Virtual Machine Monitor"
      Option "PreferredMode" "1920x1080"
    '';
  };
  
  # Reduce memory usage in VMs
  zramSwap.enable = true;
  zramSwap.memoryPercent = 80;
  
  # Disable audio in VMs by default
  sound.enable = false;
  
  # Ensure SSH is enabled
  services.openssh.enable = true;
  
  # Simplify boot process for VMs
  boot.loader.timeout = 1;
  
  # VM-specific packages
  environment.systemPackages = with pkgs; [
    spice-vdagent
    wget
    curl
    vim
    git
    htop
    parted
    gptfdisk
    i3-gaps
    dmenu
    i3status
  ];
}
