{ config, lib, pkgs, ... }:
{
  virtualisation.vmware.guest.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.xserver.videoDrivers = [ "vmware" "qxl" "virtio" ];
  environment.systemPackages = with pkgs; [
    open-vm-tools
    qemu-guest-agent
    spice-vdagent
  ];
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
  '';
}
