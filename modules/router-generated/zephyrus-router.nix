{ config, pkgs, lib, ... }:

let
  inherit (pkgs.lib) mkForce;
  
  # Detection script - simplified for router-only operation
  detectionScript = pkgs.writeShellScript "detect-router-mode" ''
    # Always router mode - this system is configured for router operation
    echo "router"
  '';

  # Service to maintain router infrastructure 
  maintainRouterModeScript = pkgs.writeShellScript "maintain-router-mode" ''
    PATH="/run/current-system/sw/bin:/run/current-system/sw/sbin:$PATH"
    
    echo "Maintaining router configuration..."
    
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
    
    echo "✅ Router mode maintenance complete"
  '';

in
{

###########################
# BEGIN ROUTER SERVICES   #
###########################

# System labels for identification - router mode is now default
system.nixos.label = "router-setup";

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
  
  # Status command
  (writeShellScriptBin "splix-status" ''
    #!/bin/sh
    echo "🖥️  Splix Router System Status"
    echo "=============================="
    
    # Detect current mode
    current_label=$(nixos-version 2>/dev/null | grep -o '[a-zA-Z-]*setup' || echo "unknown")
    echo "Current Mode: $current_label"
    echo ""
    
    echo "Router VM Status:"
    sudo virsh list --all | grep router || echo "No router VMs found"
    echo ""
    echo "Network Bridges:"
    ip link show | grep virbr | head -5 || echo "No router bridges found"
  '')
];

# Router VFIO configuration (always imported, but conditionally enabled)
imports = [ ./zephyrus-passthrough.nix ];

# Blacklist WiFi driver for router operation
boot.blacklistedKernelModules = lib.mkIf (config.system.nixos.label == "router-setup") [ "iwlwifi" ];

# Set default route through router VM (NixOS way)
networking.defaultGateway = lib.mkIf (config.system.nixos.label == "router-setup") {
    address = "192.168.100.253";
    interface = "virbr1";
};

# Auto-start router VM service (only defined in router mode)
systemd.services.router-vm-autostart = lib.mkIf (config.system.nixos.label == "router-setup") {
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

# Base mode specialisation (fallback option)
specialisation.base.configuration = {
    system.nixos.label = lib.mkForce "base-setup";
};

##########################
#  END ROUTER SERVICES   #
##########################

}