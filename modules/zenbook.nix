{ config, pkgs, ... }:

{

# Intel graphics and hardware acceleration
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver
  vaapiIntel
  vaapiVdpau
  libvdpau-va-gl
];

# Intel CPU optimizations
hardware.cpu.intel.updateMicrocode = true;

# Enable power management services
services.power-profiles-daemon.enable = true;
services.thermald.enable = true;

# Basic Intel OpenCL support
environment.systemPackages = with pkgs; [
  intel-compute-runtime
  ocl-icd
];

# Enable bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};

services.blueman.enable = true;

}
