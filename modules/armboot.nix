#    __                __          _     
#   / /_  ____  ____  / /_  ____  (_)  __
#  / __ \/ __ \/ __ \/ __/ / __ \/ / |/_/
# / /_/ / /_/ / /_/ / /__ / / / / />  <  
#/_.___/\____/\____/\__(_)_/ /_/_/_/|_|  
                                        
{ config, lib, pkgs, modulesPath, ... }:

{

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cb365a20-cc66-4f98-bb37-049897bab849";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2750-B3E6";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

# Bootloader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;


}
                                        
