{ config, pkgs, ... }:

{

environment.systemPackages = with pkgs; [

# Packages parsed with nixp.nix will be parsed below
  #monsoon
  asciiquarium
  monsoon
];

}
