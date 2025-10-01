{ config, lib, pkgs, ... }:
{
virtualisation.vmware.guest.enable = true;
services.qemuGuest.enable = true;
services.spice-vdagentd.enable = true;

services.xserver = {
    videoDrivers = [ "virtio" "qxl" "vmware" "modesetting" ];

    displayManager.sessionCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2560x1440" 312.25 2560 2752 3024 3488 1440 1443 1448 1493 -hsync +vsync 2>/dev/null || true
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 2560x1440 2>/dev/null || true
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 2560x1440 2>/dev/null || true
        ${pkgs.xorg.xrandr}/bin/xrandr --auto
        ${pkgs.spice-vdagent}/bin/spice-vdagent
    '';
};

boot.initrd.availableKernelModules = [
    "virtio_balloon" "virtio_blk" "virtio_pci" "virtio_ring"
    "virtio_net" "virtio_scsi" "virtio_console"
];

powerManagement = {
    enable = false;
    cpuFreqGovernor = lib.mkDefault "performance";
};

services = {
    thermald.enable = false;
    earlyoom.enable = lib.mkDefault false;
    tlp.enable = false;
};

zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
};

environment.systemPackages = with pkgs; [
    open-vm-tools
    #qemu-guest-agent
    spice-vdagent
    spice-gtk
];

networking = {
    firewall.allowPing = true;
    useDHCP = lib.mkDefault true;
};

boot.loader.timeout = lib.mkDefault 1;
boot.kernelParams = [
    "quiet"
    "console=tty1"
    "console=ttyS0,115200n8"
];

services.openssh = {
  enable = true;
  settings = {
    X11Forwarding = true;
  };
};

}
