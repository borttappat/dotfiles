{ config, pkgs, ... }:

{


# Services
services.asusd.enable = true;

services.blueman.enable = true;
hardware.bluetooth = {
	enable = true;
	powerOnBoot = true;
	};

# Sound-extras
#services.pipewire.jack.enable = true;
#services.jack.jackd.enable = false;

  # Virtualization and VFIO Configuration
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })];
        };
        swtpm.enable = true;
        verbatimConfig = ''
          user = "traum"
          group = "kvm"
          memory_backing_dir = "/var/lib/libvirt/qemu/ram"
          nvram = [ "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd" ]
        '';
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };

  # Enable dconf (needed for virt-manager settings)
  programs.dconf.enable = true;

  # VFIO/IOMMU configuration
  boot = {
    kernelParams = [
      "quiet"
      "splash"
      "intel_iommu=on"
      "iommu=pt"
      "ipv6.disable=1"
    ];

    kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
      "kvm"
      "kvm_intel"
    ];
  };

  # Networking configuration
  ## NixOS Host Configuration
### Network Configuration (configuration.nix)

networking = {

  nameservers = [ "192.168.100.1" ];
  # Bridge interface for VM networking
  bridges.vmnet0 = {
    interfaces = [];
  };
  
  # Configure the bridge interface
  interfaces.vmnet0 = {
    ipv4.addresses = [{
      address = "192.168.100.2";
      prefixLength = 24;
    }];
  };
  
  # Default gateway configuration
  defaultGateway = {
    address = "192.168.100.1";
    interface = "vmnet0";
  };

  # Firewall configuration
  firewall = {
    enable = true;
    trustedInterfaces = [ "vmnet0" ];
    # Allow libvirt management
    allowedTCPPorts = [ 22 5900 5901 5902 ];
  };
};

  # Bootloader.
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-0097e1f0-0180-40d6-ba65-55c705b20bec".device = "/dev/disk/by-uuid/0097e1f0-0180-40d6-ba65-55c705b20bec";




# Packages
environment.systemPackages = with pkgs; [

  obs-studio
    vim
    os-prober
    virt-manager
    virt-viewer
    #virt-install
    pciutils
    libosinfo
    guestfs-tools
    OVMF
    swtpm
    spice-gtk
    win-virtio
    looking-glass-client
    qemu
    libvirt
    bridge-utils
    iptables
    tcpdump
    nftables


asusctl
bluez
blueman

];

}
