{ config, pkgs, ... }:

{

 environment.systemPackages = with pkgs; [
    
    ttyper
    terminal-typeracer
    obsidian
    ocl-icd

    ];
}
