{ config, pkgs, ... }:

{

boot.initrd.kernelModules = [ "amdgpu" ];
services.xserver.videoDrivers = [ "amdgpu" ];
hardware.opengl = {
	# Mesa
	enable = true;

	# Vulkan
	driSupport = true;
};

# Services

# Enable bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;  # Optional: automatically power-on Bluetooth at boot
};

# Enable blueman applet
services.blueman.enable = true;

# AMD Drivers and settings

# Packages

environment.systemPackages = with pkgs; [

bluez
blueman

];

}
