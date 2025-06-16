{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "acpi" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/aef9b6b7-3715-4c44-8cda-baa47da59784";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-a47644fb-9402-4573-bef2-3176182c72b6".device = "/dev/disk/by-uuid/a47644fb-9402-4573-bef2-3176182c72b6";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B0D1-76E7";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d192ce0e-8bee-4ac7-8963-cd2293248239"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

