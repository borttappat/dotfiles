{ config, pkgs, ... }:

let
  inherit (pkgs.lib) mkForce;
in
{
  # Services
  services.asusd.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Boot and Kernel Configuration
  boot = {
    kernelPackages = mkForce pkgs.linuxPackages_6_1;  # Now we can use mkForce directly
    kernelParams = [
      "quiet"
      "splash"
      "intel_iommu=on"
      "iommu=pt"
      "ipv6.disable=1"
      "nvidia-drm.modeset=1"
      "module_blacklist=nouveau"
      "acpi_osi=Linux"
      "acpi_rev_override=1"
    ];

    kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
      "kvm"
      "kvm_intel"
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    # NVIDIA module loading
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };

  # NVIDIA and Graphics Configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    cuda.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;  # Use stable version only
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

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

  # Networking configuration
  networking = {
    nameservers = [ "192.168.100.1" ];
    bridges.vmnet0 = {
      interfaces = [];
    };
    
    interfaces.vmnet0 = {
      ipv4.addresses = [{
        address = "192.168.100.2";
        prefixLength = 24;
      }];
    };
    
    defaultGateway = {
      address = "192.168.100.1";
      interface = "vmnet0";
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "vmnet0" ];
      allowedTCPPorts = [ 22 5900 5901 5902 ];
    };
  };

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-0097e1f0-0180-40d6-ba65-55c705b20bec".device = "/dev/disk/by-uuid/0097e1f0-0180-40d6-ba65-55c705b20bec";

  environment.systemPackages = with pkgs; [
    # NVIDIA Tools
    cudatoolkit
    clinfo
    nvtop
    glmark2
    vulkan-tools
    vulkan-validation-layers
    xorg.xdriinfo
    mesa-demos  # This contains glxinfo and glxgears
    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
    
    # Rest of your existing packages
    obs-studio
    vim
    os-prober
    virt-manager
    virt-viewer
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
