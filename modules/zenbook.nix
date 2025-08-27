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

    # Auto-start router VM service
    systemd.services.router-vm-autostart = {
        description = "Auto-start router VM in router mode";
        after = [ "libvirtd.service" "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "/home/traum/splix/scripts/generated-configs/deploy-router-vm.sh";
            RemainAfterExit = true;
            User = "root";
        };
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
