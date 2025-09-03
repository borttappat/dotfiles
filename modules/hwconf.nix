{ config, lib, pkgs, ... }:

let
  # Find the ESP path among the filesystems
  getEspPath = filesystems:
    let
      # Filter filesystems to find ones mounted at /boot or /boot/efi
      bootMounts = lib.filterAttrs 
        (mountPoint: _: mountPoint == "/boot" || mountPoint == "/boot/efi") 
        filesystems;
      
      # Get the first mount point (if any)
      firstBoot = lib.head (lib.attrNames bootMounts);
    in
      if firstBoot != null then firstBoot else "/boot";
  
  espPath = getEspPath config.fileSystems;
in {
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader = lib.mkForce {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = espPath;
    };
  };
}
