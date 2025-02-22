# __   ___      __              ___         
#|  \ |  _ |_/ |_ |  |   /\  |    |   /\  | 
#|__/ |___ | \ |_ |/\|  /--\ |___ |  /--\ |___
{ config, pkgs, ... }:

{
  # Enable virtualization services
  virtualisation = {
    # QEMU/KVM configuration
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull];  # For UEFI support
        };
        swtpm.enable = true;  # For TPM support
      };
    };

    # Docker configuration
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        ipv6 = true;
        "fixed-cidr-v6" = "fd00::/80";
      };
    };

    # Podman configuration (alternative to Docker)
    podman = {
      enable = true;
      dockerCompat = true;  # For Docker compatibility
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    # LXD container support
    lxd.enable = true;

    # Waydroid for Android app support
    waydroid.enable = true;
  };

  # System-level configurations
  boot = {
    # Enable kernel modules for KVM
    kernelModules = [ "kvm-intel" "kvm-amd" ];
    
    # Extra kernel parameters for virtualization
    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    
    # Load kernel modules early
    initrd.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  };

  # Security settings for virtualization
  security = {
    # TPM support
    tpm2 = {
      enable = true;
      pkcs11.enable = true;  # For PKCS#11 support
    };

    # Extra capabilities for virtualization
    virtualisation = {
      flushL1DataCache = "always";  # Protect against L1TF/Foreshadow
    };
  };

  # System packages for virtualization
  environment.systemPackages = with pkgs; [
    # QEMU/KVM tools
    virt-manager
    virt-viewer
    spice-gtk
    win-virtio  # Windows virtio drivers
    swtpm  # TPM emulator
    OVMF  # UEFI firmware
    virtiofsd  # For shared folders

    # Container tools
    docker-compose
    lazydocker  # TUI for Docker
    ctop  # Container metrics
    dive  # Analyze Docker images
    docker-gc  # Docker garbage collection
    podman-compose
    distrobox  # For running other distros in containers

    # Network tools for VMs
    bridge-utils
    dnsmasq
    iptables
    netcat

    # Storage tools
    qemu-utils  # For qcow2 management
    libguestfs  # For VM disk manipulation
    libguestfs-with-appliance

    # Misc tools
    quickemu  # Quick QEMU VMs
    gnome.gnome-boxes  # Simple VM manager
  ];

  # Add users to virtualization groups
  users.groups = {
    libvirtd = {};
    docker = {};
    kvm = {};
  };

  # System services
  systemd.services = {
    # Auto-start libvirt default network
    "libvirtd-default-net" = {
      requires = [ "libvirtd.service" ];
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
      script = ''
        ${pkgs.libvirt}/bin/virsh net-autostart default
        ${pkgs.libvirt}/bin/virsh net-start default
      '';
    };
  };

  # Network configuration for VMs
  networking = {
    firewall = {
      # Open ports for VM networking
      allowedTCPPorts = [ 
        16509  # libvirt
        5900 5901  # VNC
        3389  # RDP
      ];
      allowedUDPPorts = [ 
        8472  # Flannel overlay
      ];
    };
    
    # Bridge support for VMs
    bridges = {
      "br0" = {
        interfaces = [ ];  # Add your network interface here if needed
      };
    };
  };
}
