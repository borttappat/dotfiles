{ config, pkgs, ... }:

{
# Intel graphics and hardware acceleration
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
};

# Intel CPU optimizations
hardware.cpu.intel.updateMicrocode = true;

# Enable power management services
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
  settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };
};

services.blueman.enable = true;

# zenbook-audio module
hardware.zenbook-audio.enable = true;

# Hardware firmware (non-audio)
hardware.firmware = with pkgs; [
  linux-firmware
];

}
