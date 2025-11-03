{ config, lib, pkgs, modulesPath, ... }:
{
boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=8086:a840"
];
boot.blacklistedKernelModules = [ "iwlwifi" ];
boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];
virtualisation.libvirtd = {
    enable = true;
    qemu = {
        package = lib.mkForce pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
        };
    };
};
# Router management bridge (host <-> router VM)
networking.bridges.virbr1.interfaces = [];
networking.interfaces.virbr1 = {
    ipv4.addresses = [{
        address = "192.168.100.1";
        prefixLength = 24;
    }];
};
# VM network bridges (guest VMs <-> router VM)
networking.bridges.virbr2.interfaces = [];
networking.interfaces.virbr2 = {
    ipv4.addresses = [{
        address = "192.168.101.1";
        prefixLength = 24;
    }];
};
networking.bridges.virbr3.interfaces = [];
networking.interfaces.virbr3 = {
    ipv4.addresses = [{
        address = "192.168.102.1";
        prefixLength = 24;
    }];
};
# NEW: Isolated bridges (no host IP)
networking.bridges.virbr4.interfaces = [];
networking.bridges.virbr5.interfaces = [];
# Allow forwarding for all VM networks
networking.firewall = {
    extraCommands = ''
        # Management bridge (virbr1)
        iptables -A FORWARD -i virbr1 -j ACCEPT
        iptables -A FORWARD -o virbr1 -j ACCEPT
        iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
        # VM network bridges (virbr2, virbr3)
        iptables -A FORWARD -i virbr2 -j ACCEPT
        iptables -A FORWARD -o virbr2 -j ACCEPT
        iptables -A FORWARD -i virbr3 -j ACCEPT
        iptables -A FORWARD -o virbr3 -j ACCEPT
        # Allow inter-bridge communication through router VM
        iptables -A FORWARD -i virbr2 -o virbr1 -j ACCEPT
        iptables -A FORWARD -i virbr1 -o virbr2 -j ACCEPT
        iptables -A FORWARD -i virbr3 -o virbr1 -j ACCEPT
        iptables -A FORWARD -i virbr1 -o virbr3 -j ACCEPT
        iptables -A FORWARD -i virbr2 -o virbr3 -j ACCEPT
        iptables -A FORWARD -i virbr3 -o virbr2 -j ACCEPT
        # NEW: Isolated bridges (virbr4, virbr5)
        iptables -A FORWARD -i virbr4 -o virbr1 -j ACCEPT
        iptables -A FORWARD -i virbr1 -o virbr4 -j ACCEPT
        iptables -A FORWARD -i virbr5 -o virbr1 -j ACCEPT
        iptables -A FORWARD -i virbr1 -o virbr5 -j ACCEPT
        # Block virbr4/5 from old bridges
        iptables -A FORWARD -i virbr4 -o virbr2 -j DROP
        iptables -A FORWARD -i virbr4 -o virbr3 -j DROP
        iptables -A FORWARD -i virbr5 -o virbr2 -j DROP
        iptables -A FORWARD -i virbr5 -o virbr3 -j DROP
        iptables -A FORWARD -i virbr2 -o virbr4 -j DROP
        iptables -A FORWARD -i virbr3 -o virbr4 -j DROP
        iptables -A FORWARD -i virbr2 -o virbr5 -j DROP
        iptables -A FORWARD -i virbr3 -o virbr5 -j DROP
        # Block virbr4 <-> virbr5
        iptables -A FORWARD -i virbr4 -o virbr5 -j DROP
        iptables -A FORWARD -i virbr5 -o virbr4 -j DROP
    '';
    trustedInterfaces = [ "virbr1" "virbr2" "virbr3" ];
};
}
