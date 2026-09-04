{ config, lib, pkgs, ... }:
{

# Shared guest-agent stack: safe to import on bare metal or under any
# hypervisor. VMware's own module already self-gates correctly (its systemd
# units carry ConditionVirtualization=vmware upstream). qemu-guest-agent and
# spice-vdagentd carry no such gating upstream, so it's added explicitly
# below - without it they'd start (and fail to find their virtio-serial
# channel) even on bare metal or under VMware.
virtualisation.vmware.guest.enable = true;

services.qemuGuest.enable = true;
systemd.services.qemu-guest-agent.unitConfig.ConditionVirtualization = [ "qemu" "kvm" ];

services.spice-vdagentd.enable = true;
systemd.services.spice-vdagentd.unitConfig.ConditionVirtualization = [ "qemu" "kvm" ];

# Needed for alacritty (and anything else requiring a GL context) to find
# a usable OpenGL configuration - without this, no Mesa/DRI/libGL stack
# gets installed at all and GL clients fail outright, even falling back
# to software rendering (llvmpipe) needs the package set this pulls in.
hardware.graphics.enable = lib.mkDefault true;

services.xserver = {
    videoDrivers = [ "qxl" "vmware" "modesetting" ];
    displayManager.sessionCommands = ''
        ${pkgs.xrandr}/bin/xrandr --newmode "2560x1440" 312.25 2560 2752 3024 3488 1440 1443 1448 1493 -hsync +vsync 2>/dev/null || true
        ${pkgs.xrandr}/bin/xrandr --addmode Virtual-1 2560x1440 2>/dev/null || true
        ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --mode 2560x1440 2>/dev/null || true
        ${pkgs.xrandr}/bin/xrandr --auto
        ${pkgs.spice-vdagent}/bin/spice-vdagent -x &
    '';
};

# Union of QEMU/KVM (virtio) and VMware's default virtual hardware
# (PVSCSI/LSI Logic SAS controller, VMXNET3 NIC), so the same image boots
# under either hypervisor without per-machine editing. Listing a module
# that isn't present for the actual hardware is a no-op.
boot.initrd.availableKernelModules = [
    "virtio_balloon" "virtio_blk" "virtio_pci" "virtio_ring"
    "virtio_net" "virtio_scsi" "virtio_console"
    "vmw_pvscsi" "mptspi" "mptbase" "vmxnet3"
];

environment.systemPackages = with pkgs; [
    open-vm-tools
    spice-vdagent
    spice-gtk
];

}
