{ config, pkgs, lib, ... }:

{
  # QEMU Guest Agent and SPICE for VM integration
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # VM packages for clipboard and resolution
  environment.systemPackages = with pkgs; [
    spice-vdagent
    xorg.xrandr
    xclip
    xsel
  ];

  # Virtio modules for VM hardware
  boot.initrd.availableKernelModules = [
    "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net"
    "virtio_balloon" "virtio_console" "qxl"
  ];
  boot.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_gpu" ];

  # VM performance optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "fs.file-max" = 65536;
  };

  # Resolution and display for VMs
  services.xserver.videoDrivers = [ "qxl" "virtio" "vesa" ];
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
    ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 "1920x1080_60.00" 2>/dev/null || true
    ${pkgs.xorg.xrandr}/bin/xrandr --addmode qxl-0 "1920x1080_60.00" 2>/dev/null || true
    ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || \
    ${pkgs.xorg.xrandr}/bin/xrandr --output qxl-0 --mode 1920x1080 2>/dev/null || true
  '';

  # Clipboard sharing service
  systemd.user.services.spice-vdagent = {
    description = "SPICE vdagent for clipboard sharing";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "always";
      RestartSec = 3;
    };
  };

  # Disable unnecessary services for VMs
  systemd.services.NetworkManager-wait-online.enable = false;
  services.udisks2.enable = lib.mkDefault false;
  services.power-profiles-daemon.enable = lib.mkDefault false;
}
