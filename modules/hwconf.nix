{ config, lib, pkgs, ... }:

let
  getEspPath = filesystems:
    let
      bootMounts = lib.filterAttrs 
        (mountPoint: _: mountPoint == "/boot" || mountPoint == "/boot/efi") 
        filesystems;
      
      bootMountsList = lib.attrNames bootMounts;
      firstBoot = if bootMountsList != [] then lib.head bootMountsList else null;
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
