{ config, pkgs, ... }:

{

 environment.systemPackages = with pkgs; [


    # recent ucategorized installs

    # Categorized
    ttyper
    terminal-typeracer
    obsidian
    opencl-info
    sleuthkit
    bully

    ];
}
