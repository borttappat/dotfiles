{ config, pkgs, lib, ... }:

{

###########################
# BEGIN ROUTER SPEC SETUP #
###########################

# System labels for identification
system.nixos.label = "base-setup";

# Router specialisation
specialisation.router.configuration = {
    system.nixos.label = lib.mkForce "router-setup";

    # Import router VFIO configuration
    imports = [ ./router-generated/zenbook-passthrough.nix ];

    systemd.services.router-default-route = {
        description = "Set default route through router VM";
        after = [ "router-vm-autostart.service" "network.target" ];
        wants = [ "router-vm-autostart.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
        };
        script = ''
            sleep 30
            ${pkgs.iproute2}/bin/ip route add default via 192.168.100.253 dev virbr1 || true
        '';
    };
};

##########################
#  END ROUTER SPEC SETUP #
##########################

# Intel graphics and hardware acceleration
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-compute-runtime
  ];
};

# Hardware-specific hostname
networking.hostName = lib.mkForce "zen";

# Intel CPU optimizations
hardware.cpu.intel.updateMicrocode = true;

# Enable power management services
services.thermald.enable = true;

# Basic Intel OpenCL support
environment.systemPackages = with pkgs; [
  intel-compute-runtime
  ocl-icd
  intel-ocl

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

# Enable bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };
};

services.blueman.enable = true;

# Trying to get hashcat to work :)
boot.kernelParams = [ "i915.enable_guc=3" "i915.enable_fbc=1" ];

# Hardware firmware (non-audio)
hardware.firmware = with pkgs; [
  linux-firmware
];

}
