{ config, lib, pkgs, ... }:
{
  # VM detection and conditional guest tools
  virtualisation.vmware.guest.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Optimized video drivers with better ordering
  services.xserver.videoDrivers = [ "virtio" "qxl" "vmware" "modesetting" ];

  # VM-specific kernel modules
  boot.initrd.availableKernelModules = [
    "virtio_balloon" "virtio_blk" "virtio_pci" "virtio_ring"
    "virtio_net" "virtio_scsi" "virtio_console"
  ];

  # Performance optimizations for VMs
  powerManagement = {
    enable = false;
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  # Disable unnecessary services in VMs
  services = {
    thermald.enable = false;
    earlyoom.enable = lib.mkDefault false;
    tlp.enable = false;
  };

  # Memory optimization
  zramSwap = {
    enable = true;
    memoryPercent = 50;  # More conservative than the 80% in vm-common
    algorithm = "zstd";
  };

  # VM-optimized packages
  environment.systemPackages = with pkgs; [
    open-vm-tools
    qemu-guest-agent
    spice-vdagent
    spice-gtk
  ];

  # Display management with better resolution handling
  services.xserver = {
    displayManager.sessionCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --auto
      ${pkgs.spice-vdagent}/bin/spice-vdagent
    '';
    
    # Better resolution defaults
    resolutions = [
      { x = 1920; y = 1080; }
      { x = 1600; y = 900; }
      { x = 1280; y = 720; }
    ];
  };

  # Clipboard integration
  services.xserver.desktopManager.sessionCommands = ''
    ${pkgs.spice-vdagent}/bin/spice-vdagent &
  '';

  # Network optimizations for VMs
  networking = {
    firewall.allowPing = true;
    useDHCP = lib.mkDefault true;
  };

  # Faster boot for VMs
  boot.loader.timeout = lib.mkDefault 1;
  boot.kernelParams = [ 
    "quiet" 
    "console=tty1" 
    "console=ttyS0,115200n8" 
  ];
}
