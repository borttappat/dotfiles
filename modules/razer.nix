{ config, pkgs, ... }:

{


# Services

# OpenRGB
services.hardware.openrgb.enable = true;


# Intel OpenCL drivers
hardware.graphics.extraPackages = [ pkgs.intel-compute-runtime ];

# Packages

environment.systemPackages = with pkgs; [

ocl-icd

];

}
