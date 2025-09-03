{ config, lib, pkgs, ... }:

let
  # Check if we're running in a VM
  isVM = builtins.any (mod: lib.hasInfix "qemu-guest" (toString mod)) config.imports
    || builtins.any (mod: lib.hasInfix "virtualbox-guest" (toString mod)) config.imports
    || config.virtualisation.vmware.guest.enable or false;

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

  boot.loader = lib.mkForce (
    if isVM then {
      # Simpler configuration for VMs
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = false;  # Usually not needed in VMs
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";  # Simple default for VMs
      };
    } else {
      # Full configuration for physical machines
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
    }
  );
}
