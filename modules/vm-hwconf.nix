{ config, pkgs, lib, ... }:
let
  hostConfiguration = (import /etc/nixos/configuration.nix) { inherit config pkgs lib; };
in
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    device = hostConfiguration.boot.loader.grub.device;
    useOSProber = false;
  };

  # Pulled straight from the installer-generated configuration.nix so a new
  # encrypted VM never needs its luks.devices stanza copied in by hand.
  boot.initrd.luks.devices = hostConfiguration.boot.initrd.luks.devices or { };
}
