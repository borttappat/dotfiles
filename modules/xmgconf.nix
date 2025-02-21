#    __                __          _     
#   / /_  ____  ____  / /_  ____  (_)  __
#  / __ \/ __ \/ __ \/ __/ / __ \/ / |/_/
# / /_/ / /_/ / /_/ / /__ / / / / />  <  
#/_.___/\____/\____/\__(_)_/ /_/_/_/|_|  
                                        
{ config, lib, pkgs, modulesPath, ... }:

{


  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/232c7246-bfe3-4603-81c9-2b9700b8181b";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-195c8d39-49e0-43de-99fa-64f614d8cc2e".device = "/dev/disk/by-uuid/195c8d39-49e0-43de-99fa-64f614d8cc2e";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3AF9-A9BA";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

# Bootloader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;


}
                                        
