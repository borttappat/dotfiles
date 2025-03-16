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

  # Graphics Configuration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  # Boot and Kernel Configuration
  boot = {
    kernelPackages = mkForce pkgs.linuxPackages_6_1;
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

  # Enhanced NVIDIA and Graphics Configuration
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;  # Enhanced power management
    };
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      # Use hardware-configuration.nix values here if they're different
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # X Server Configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA Container Support
  hardware.nvidia-container-toolkit.enable = true;

  # Add CUDA to system environment
  environment = {
    variables = {
      CUDA_PATH = "${pkgs.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
    };
    
    extraInit = ''
      # Extend existing LD_LIBRARY_PATH with CUDA libraries
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.cudatoolkit}/lib
    '';
  };

  # Virtualization Configuration
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
    
    # Docker configuration
    docker = {
      enable = true;
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
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.initrd.luks.devices."luks-0097e1f0-0180-40d6-ba65-55c705b20bec".device = "/dev/disk/by-uuid/0097e1f0-0180-40d6-ba65-55c705b20bec";

  environment.systemPackages = with pkgs; [
    # CUDA and NVIDIA Tools
    cudatoolkit
    linuxPackages.nvidia_x11
    
    # NVIDIA Development Tools
    clinfo
    nvtopPackages.full
    glmark2
    vulkan-tools
    vulkan-validation-layers
    xorg.xdriinfo
    mesa-demos
    
    # Development Tools
    gcc
    gdb
    cmake
    gnumake
    python3
    python3Packages.numpy
    python3Packages.pytorch
    
    # Monitoring and Debugging
    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
    (writeShellScriptBin "nvidia-smi-watch" ''
      while true; do
        clear
        nvidia-smi
        sleep 1
      done
    '')
    
    # System and VM Tools
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
