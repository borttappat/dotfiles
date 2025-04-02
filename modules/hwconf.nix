{ config, lib, pkgs, ... }:

let
  # Get the ESP path from hardware-configuration if available
  espPath = lib.findFirst
    (fs: fs.mountPoint == "/boot" || fs.mountPoint == "/boot/efi")
    { mountPoint = "/boot"; } # Default fallback if not found
    config.fileSystems;
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
      efiSysMountPoint = espPath.mountPoint;
    };
  };
}
