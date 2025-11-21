{ config, pkgs, lib, ... }:

let
  inherit (pkgs.lib) mkForce;
  
  # Detection script that determines if we should be in router mode
  detectionScript = pkgs.writeShellScript "detect-router-mode" ''
    # Check if VFIO PCI module is loaded (indicates router mode hardware setup)
    if lsmod | grep -q "vfio_pci"; then
      echo "router"
      exit 0
    fi
    
    # Check if router bridges exist (indicates router mode network setup)
    if [[ -d /sys/class/net/virbr1 ]] && ip link show virbr1 >/dev/null 2>&1; then
      echo "router"
      exit 0
    fi
    
    # Check current NixOS generation label
    current_label=$(nixos-version | grep -o '[a-zA-Z-]*setup' || echo "base-setup")
    if [[ "$current_label" == "router-setup" ]]; then
      echo "router"
      exit 0
    fi
    
    # Default to base mode
    echo "base"
  '';

  # Service to maintain router mode state
  maintainRouterModeScript = pkgs.writeShellScript "maintain-router-mode" ''
    current_mode=$(${detectionScript})
    
    if [[ "$current_mode" == "router" ]]; then
      echo "Detected router mode - ensuring router configuration is maintained"
      
      # Ensure virbr1 bridge exists and is configured
      if ! ip link show virbr1 >/dev/null 2>&1; then
        echo "Creating virbr1 bridge..."
        ip link add virbr1 type bridge
        ip addr add 192.168.100.1/24 dev virbr1
        ip link set virbr1 up
      fi
      
      # Ensure VFIO modules are loaded if hardware supports it
      if ! lsmod | grep -q "vfio_pci"; then
        echo "Loading VFIO modules for router mode..."
        modprobe vfio_pci 2>/dev/null || true
      fi
      
      echo "Router mode maintenance complete"
    else
      echo "Base mode detected - no router maintenance needed"
    fi
  '';

in
{

###########################
# BEGIN ROUTER SERVICES   #
###########################

# System labels for identification
system.nixos.label = "base-setup";

# Auto-mode detection and maintenance services
systemd.services.splix-mode-detection = {
  description = "Splix Router/Base Mode Detection and Maintenance";
  after = [ "network.target" "libvirtd.service" ];
  wants = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = maintainRouterModeScript;
    User = "root";
  };
  
  # Run after any system reconfiguration
  unitConfig = {
    ConditionPathExists = "!/tmp/splix-mode-maintained";
  };
};

# Post-rebuild maintenance service
systemd.services.splix-post-rebuild-maintenance = {
  description = "Splix Post-Rebuild Mode Maintenance";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = pkgs.writeShellScript "post-rebuild-maintain" ''
      ${maintainRouterModeScript}
      # Create marker to prevent boot service from running unnecessarily
      touch /tmp/splix-mode-maintained
    '';
    User = "root";
  };
};

# Make detection script available system-wide
environment.systemPackages = with pkgs; lib.mkAfter [
  (writeShellScriptBin "splix-detect-mode" ''
    ${detectionScript}
  '')
  (writeShellScriptBin "splix-maintain-mode" ''
    ${maintainRouterModeScript}
  '')
  
  # Router mode switching commands
  (writeShellScriptBin "switch-to-router" ''
    #!/bin/sh
    echo "Switching to router mode..."
    sudo /run/current-system/specialisation/router/bin/switch-to-configuration switch
    echo "✅ Router mode activated"
    echo "Router VM should start automatically"
  '')
  
  (writeShellScriptBin "switch-to-base" ''
    #!/bin/sh
    echo "Switching to base mode..."
    sudo /run/current-system/bin/switch-to-configuration switch
    echo "✅ Base mode activated"
    echo "WiFi should be restored"
  '')
];

# Router specialisation
specialisation.router.configuration = {
    system.nixos.label = lib.mkForce "router-setup";
    
    # Import router VFIO configuration
    imports = [ ./zephyrus-passthrough.nix ];
    
    # Set default route through router VM (NixOS way)
    networking.defaultGateway = {
        address = "192.168.100.253";
        interface = "virbr1";
    };
    
    # Auto-start router VM service (starts existing VM without recreating)
    systemd.services.router-vm-autostart = {
        description = "Auto-start existing router VM in router mode";
        after = [ 
            "libvirtd.service" 
            "network.target"
            "network-online.target"
        ];
        wants = [ "libvirtd.service" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "/home/traum/splix/generated/scripts/autostart-router-vm.sh";
            RemainAfterExit = true;
            User = "root";
            TimeoutStartSec = "120s";
            # Ensure proper PATH for systemd service
            Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin";
        };
    };
};

##########################
#  END ROUTER SERVICES   #
##########################

}