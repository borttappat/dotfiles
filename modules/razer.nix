{ config, pkgs, ... }:

{


# Services

# OpenRGB
services.hardware.openrgb.enable = true;


# Packages

environment.systemPackages = with pkgs; [

# Packages parsed with nixp.nix will be parsed below
];

}
