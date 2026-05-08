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
}
