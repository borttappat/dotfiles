{ config, lib, pkgs, ... }:

{
# Enable IOMMU for passthrough
boot.kernelParams = [ 
"intel_iommu=on" 
"iommu=pt" 
"vfio-pci.ids=8086:a840"
];

# Load VFIO modules
boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
boot.blacklistedKernelModules = [ "iwlwifi" ];

# Ensure libvirtd has access to VFIO devices
virtualisation.libvirtd = {
enable = true;
qemu = {
package = lib.mkForce pkgs.qemu_kvm;
runAsRoot = true;
swtpm.enable = true;
ovmf = {
enable = true;
packages = [ pkgs.OVMF.fd ];
};
};
};

# Create network bridge for VM communication
networking.bridges.virbr1.interfaces = [];
networking.interfaces.virbr1.ipv4.addresses = [{
address = "192.168.100.1";
prefixLength = 24;
}];

# Allow forwarding for VM network
networking.firewall = {
extraCommands = ''
iptables -A FORWARD -i virbr1 -j ACCEPT
iptables -A FORWARD -o virbr1 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE
'';
trustedInterfaces = [ "virbr1" ];
};

# Emergency recovery service
systemd.services.network-emergency = {
description = "Emergency network recovery";
serviceConfig = {
Type = "oneshot";
ExecStart = "/home/traum/splix/scripts/generated-configs/emergency-recovery.sh";
RemainAfterExit = false;
};
};
}
