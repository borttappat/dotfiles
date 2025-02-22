#       __      __            __
#.--.--|__.----|  |_   .-----|__.--.--.
#|  |  |  |   _|   _|__|     |  |_   _|
# \___/|__|__| |____|__|__|__|__|__.__|

 { config, pkgs, lib, ... }:

let
  isIntel = pkgs.stdenv.hostPlatform.isx86_64 && config.hardware.cpu.intel.updateMicrocode;
  isAMD = pkgs.stdenv.hostPlatform.isx86_64 && config.hardware.cpu.amd.updateMicrocode;
in
{
  options.virtualisation = {
    useDocker = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use Docker instead of Podman";
    };
  };

  config = {
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

      # Choose between Docker and Podman based on useDocker option
      docker = lib.mkIf config.virtualisation.useDocker {
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

      podman = lib.mkIf (!config.virtualisation.useDocker) {
        enable = true;
        dockerCompat = true;  # Only enabled when Docker is disabled
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
      # Basic KVM configuration
      kernelModules = [ "kvm" "kvm-intel" "kvm-amd" ];
      
      # Basic IOMMU parameters
      kernelParams = [ "iommu=pt" ];
    };

    # Security settings for virtualization
    security = {
      # TPM support
      tpm2 = {
        enable = true;
        pkcs11.enable = true;  # For PKCS#11 support
      };
    };

    # Enable dconf (needed for virt-manager settings)
    programs.dconf.enable = true;

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
      gnome-boxes  # Simple VM manager
    ];

    # Add users to virtualization groups
    users.groups = {
      libvirtd = {};
      kvm = {};
    } // lib.mkIf config.virtualisation.useDocker {
      docker = {};
    };

    # System services
    systemd.services = {
      # Auto-start libvirt default network
      "libvirtd-default-net" = {
        requires = [ "libvirtd.service" ];
        after = [ "libvirtd.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.libvirt ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
        script = ''
          # Check if network exists
          if ! virsh net-info default >/dev/null 2>&1; then
            virsh net-define ${pkgs.writeText "libvirt-default-network.xml" ''
              <network>
                <name>default</name>
                <bridge name="virbr0"/>
                <forward mode="nat"/>
                <ip address="192.168.122.1" netmask="255.255.255.0">
                  <dhcp>
                    <range start="192.168.122.2" end="192.168.122.254"/>
                  </dhcp>
                </ip>
              </network>
            ''}
          fi

          # Enable autostart if not already enabled
          if ! virsh net-info default | grep -q "Autostart.*yes"; then
            virsh net-autostart default
          fi

          # Start network if not already active
          if ! virsh net-info default | grep -q "Active.*yes"; then
            virsh net-start default
          fi
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
        # Allow traffic from virtual networks
        extraCommands = ''
          # Allow traffic from libvirt default network
          iptables -I nixos-fw -i virbr0 -j ACCEPT
          iptables -I nixos-fw -o virbr0 -j ACCEPT
          # Allow traffic from VMs to reach the internet through Mullvad
          iptables -I FORWARD -i virbr0 -j ACCEPT
          iptables -I FORWARD -o virbr0 -j ACCEPT
          iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j MASQUERADE
        '';
      };
      
      # Bridge support for VMs
      bridges = {
        "br0" = {
          interfaces = [ ];  # Add your network interface here if needed
        };
      };
    };

    # Add groups to user "traum"
    users.users.traum.extraGroups = [ "libvirtd" "kvm" ] 
      ++ lib.optional config.virtualisation.useDocker "docker";
  };
}
