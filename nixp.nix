{ config, pkgs, ... }:

{

environment.systemPackages = with pkgs; [

# Packages parsed with nixp.nix will be parsed below
test2
test

