#       __      __            __
#.--.--|__.----|  |_   .-----|__.--.--.
#|  |  |  |   _|   _|__|     |  |_   _|
# \___/|__|__| |____|__|__|__|__|__.__|
{ config, pkgs, lib, ... }:

{
  options = {
    virtualisation = {
      useDocker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use Docker instead of Podman";
      };
      mainUser = lib.mkOption {
        type = lib.types.str;
        default = "traum";
        description = "Main user for virtualization permissions";
      };
    };
  };

  config = {
    # Virtualization services
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu;
          ovmf = {
            enable = true;
            packages = [pkgs.OVMFFull];
          };
          swtpm.enable = true;
        };
      };

      docker = lib.mkIf config.virtualisation.useDocker {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };

      podman = lib.mkIf (!config.virtualisation.useDocker) {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };

    # Libvirt networks
    networking = {
      firewall = {
        allowedTCPPorts = [ 
          16509  # libvirt
          5900 5901  # VNC
          3389  # RDP
        ];
        allowedUDPPorts = [ 
          8472  # Flannel overlay
        ];
        checkReversePath = "loose";
        trustedInterfaces = [ "virbr0" ];
      };

      nat = {
        enable = true;
        internalInterfaces = ["virbr0"];
        externalInterface = "wlo1";  # Adjust this to your network interface
      };
    };

    # Enable IP forwarding
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
    };

    # Default network configuration for libvirt
    environment.etc."libvirt/qemu/networks/default.xml" = {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <network>
          <name>default</name>
          <forward mode="nat">
            <nat>
              <port start='1024' end='65535'/>
            </nat>
          </forward>
          <bridge name="virbr0" stp='on' delay='0'/>
          <dns>
            <forwarder addr="194.242.2.2"/>
          </dns>
          <ip address="192.168.122.1" netmask="255.255.255.0">
            <dhcp>
              <range start="192.168.122.2" end="192.168.122.254"/>
            </dhcp>
          </ip>
        </network>
      '';
      user = "root";
      group = "root";
      mode = "0644";
    };

    # System packages and configuration
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice-gtk
      win-virtio
      swtpm
      OVMF
      virtiofsd
      bridge-utils
      dnsmasq  # needed for libvirt but will be managed by libvirt
      iptables
    ] ++ lib.optionals config.virtualisation.useDocker [
      docker-compose
      lazydocker
    ];

    # Do NOT enable the system dnsmasq service as libvirt manages its own instance
    services.dnsmasq.enable = false;

    # User groups
    users.groups = {
      libvirtd = {};
      kvm = {};
    } // lib.mkIf config.virtualisation.useDocker {
      docker = {};
    };

    # Add current user to virtualization groups
    users.users.${config.virtualisation.mainUser}.extraGroups = [ "libvirtd" "kvm" ] 
      ++ lib.optional config.virtualisation.useDocker "docker";

    # Required services
    systemd.services.libvirtd = {
      path = [ pkgs.bridge-utils ];
      preStart = ''
        mkdir -p /var/lib/libvirt/qemu/networks/autostart
        mkdir -p /etc/libvirt/qemu/networks/
        chmod 755 /var/lib/libvirt/qemu/networks/autostart
        chmod 755 /etc/libvirt/qemu/networks/
      '';
    };

    # Ensure default network is started
    systemd.services.libvirt-default-network = {
      description = "Libvirt Default Network";
      wantedBy = [ "multi-user.target" ];
      requires = [ "libvirtd.service" ];
      after = [ "libvirtd.service" "network.target" ];
      path = with pkgs; [ libvirt dnsmasq ];
      environment = {
        LC_ALL = "C";
      };
      preStart = ''
        mkdir -p /var/lib/libvirt/qemu/networks/
        mkdir -p /var/lib/libvirt/qemu/networks/autostart/
        chmod 755 /var/lib/libvirt/qemu/networks{,/autostart}
      '';
      script = ''
        set -x

        # Make sure libvirtd is ready
        timeout=30
        while [ $timeout -gt 0 ]; do
          if virsh connect "qemu:///system" >/dev/null 2>&1; then
            break
          fi
          sleep 1
          timeout=$((timeout - 1))
        done

        if [ $timeout -eq 0 ]; then
          echo "Timeout waiting for libvirtd"
          exit 1
        fi

        # Clean up any existing network
        virsh net-destroy default >/dev/null 2>&1 || true
        virsh net-undefine default >/dev/null 2>&1 || true

        echo "Creating network from: /etc/libvirt/qemu/networks/default.xml"
        virsh net-define /etc/libvirt/qemu/networks/default.xml
        
        virsh net-autostart default
        virsh net-start default

        echo "Current networks:"
        virsh net-list --all
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        Restart = "on-failure";
        RestartSec = "1s";
      };
    };
  };
}

