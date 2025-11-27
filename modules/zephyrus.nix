{ config, pkgs, lib, ... }:

  let
    inherit (pkgs.lib) mkForce;

  in
  {

  imports = [
    ./router-generated/zephyrus-consolidated.nix  # Unified module (old 3-file setup preserved as backup)
  ];

  # Make detection script available system-wide and other packages
  environment.systemPackages = with pkgs; lib.mkAfter [

    # Add a script to set battery charge limit
    (writeShellScriptBin "set-battery-limit" ''
      #!/bin/sh
      echo "Setting battery charge limit to 80%..."
      ${pkgs.asusctl}/bin/asusctl -c 80
      echo "Battery charge limit set."
    '')

    # Power management tools
    powertop         # For analyzing power usage
    acpi             # For battery info and control
    acpid            # For ACPI events
    s-tui            # Terminal UI for monitoring CPU
    intel-gpu-tools  # Tools for managing Intel GPU

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

    (writeShellScriptBin "performance-mode" ''
      #!/bin/sh
      echo "Switching to performance mode..."
      sudo cpupower frequency-set -g performance
      echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
      echo " CPU set to performance mode"

      echo "Starting services..."
      sudo systemctl start docker.service
      sudo systemctl start libvirtd.service
      echo "Done! System optimized for performance."
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

  # ASUS-specific services
  services.asusd = {
      enable = true;
  };

  # Bluetooth configuration
  services.blueman.enable = true;
  hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      # Power saving settings for Bluetooth
      settings = {
          General = {
              FastConnectable = false;
              JustWorksRepairing = "always";
              Privacy = "device";
              Experimental = false;
          };
      };
  };

  # Host-specific name
  networking.hostName = lib.mkForce "zeph";

  # Advanced Power Management
  powerManagement = {
      enable = true;
      powertop.enable = true; # Enables powertop auto-tune on startup
      cpuFreqGovernor = "powersave"; # Use powersave when on battery
  };

  # TLP for advanced power management
  services.tlp = {
      enable = true;
      settings = {
          # CPU settings
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 60; # Limit maximum performance on battery

          # Platform profile
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          # PCIe power management (ASPM)
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";

          # Kernel NMI watchdog
          NMI_WATCHDOG = 0;

          # Runtime Power Management for PCIe devices
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";

          # Audio power management
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";

          # WiFi power saving
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";

          # USB autosuspend
          USB_AUTOSUSPEND = 1;

          # Battery care settings
          START_CHARGE_THRESH_BAT0 = 40; # Start charging when below 40%
          STOP_CHARGE_THRESH_BAT0 = 80;  # Stop charging at 80%
          };
  };


  # Auto-cpufreq for dynamic CPU frequency management
  services.auto-cpufreq = {
      enable = true;
      settings = {
          battery = {
              governor = "powersave";
              turbo = "never"; # Disable turbo boost on battery
          };
          charger = {
              governor = "performance";
              turbo = "auto";
          };
      };
  };

  # Thermald for better thermal management
  services.thermald.enable = true;

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

          # Power management related parameters
          "intel_pstate=active"      # Enable Intel P-state driver
          "intel_idle.max_cstate=3"  # Set maximum C-state for Intel CPUs
          "pcie_aspm=force"          # Force PCIe Active State Power Management
          "mem_sleep_default=deep"   # Use deep sleep by default
          "nvme.noacpi=1"            # Improved NVMe power management
          "i915.enable_psr=1"        # Panel Self Refresh for Intel graphics

          # Basic parameters
          "ipv6.disable=1"
          "nvidia-drm.modeset=1"
          "module_blacklist=nouveau"
          "acpi_osi=Linux"
          "acpi_rev_override=1"
      ];

      kernelModules = [
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

  # Kernel sysctl settings for power management
  boot.kernel.sysctl = {
      "vm.laptop_mode" = lib.mkForce 5;
      "vm.dirty_writeback_centisecs" = lib.mkForce 1500;
      "vm.swappiness" = lib.mkForce 10;  # Force this value even if defined elsewhere
  };

  # Runtime PM for PCI devices
  services.udev.extraRules = ''
      # Enable runtime power management for all PCI devices
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"

      # Enable ASPM for PCIe devices
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/aspm_policy}="powersupersave"

      # Autosuspend USB devices
      ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto", ATTR{power/autosuspend}="1"
  '';

  # Enhanced NVIDIA and Graphics Configuration
  hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement = {
          enable = true;
          finegrained = true;
      };

      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
          offload = {
              enable = true;
              enableOffloadCmd = true; # Create nvidia-offload command
          };

          # Properly identify GPU bus IDs
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";

          # Set NVIDIA GPU to power down when not in use
          sync.enable = false; # Using offload instead of sync for power saving
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

  # Disable unnecessary services when on battery
  powerManagement.powerDownCommands = ''
      systemctl stop docker.service || true
      systemctl stop libvirtd.service || true
  '';

  powerManagement.powerUpCommands = ''
      systemctl start docker.service || true
      systemctl start libvirtd.service || true
  '';

  # Enable dconf (needed for virt-manager settings)
  programs.dconf.enable = true;

  # Networking configuration
  networking = {
      # Use standard DHCP configuration
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true;

      # Keep firewall settings
      firewall = {
          enable = true;
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

          extraConfig = ''
              function os_prober {
              ( /usr/bin/os-prober || true ) 2>/dev/null
              }
          '';
      };
      efi.canTouchEfiVariables = true;
  };

  }
