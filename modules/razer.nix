{ config, pkgs, ... }:

{


# Services

# OpenRGB
services.hardware.openrgb.enable = true;

# Enable bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;  # Optional: automatically power-on Bluetooth at boot
};

# Enable blueman applet
services.blueman.enable = true;


# Intel OpenCL drivers
hardware.graphics.extraPackages = [ pkgs.intel-compute-runtime ];

# Packages

environment.systemPackages = with pkgs; [

ocl-icd
intel-ocl
intel-compute-runtime

bluez
blueman

];

}
