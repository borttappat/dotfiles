{ config, lib, pkgs, ... }:
{

imports = [ ./guest-agents.nix ];

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

networking = {
    firewall.allowPing = true;
    useDHCP = lib.mkDefault true;
};

# Keep this guest off the network as a router/relay: pentesting.nix pulls in
# docker (via services.nix/pentesting.nix), whose own NixOS module forces
# net.ipv4.conf.all/default.forwarding on (priority 98, same sysctl as
# ip_forward) to support its bridge networking. Disabling docker below removes
# that override at the source; the explicit mkForce here is a backstop against
# any other imported module doing the same in the future.
virtualisation.docker.enable = lib.mkForce false;
boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkForce 0;
    "net.ipv4.conf.all.forwarding" = lib.mkForce 0;
    "net.ipv4.conf.default.forwarding" = lib.mkForce 0;
};

# Reduce footprint: no local DB/file-sync/remote-shell daemons needed for a
# throwaway test guest.
services.rsyncd.enable = lib.mkForce false;
services.mysql.enable = lib.mkForce false;
services.openssh.enable = lib.mkForce false;

boot.loader.timeout = lib.mkDefault 1;
boot.kernelParams = [
    "quiet"
    "console=ttyS0,115200n8"
    "console=tty1"
];

}
