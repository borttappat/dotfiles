{ config, pkgs, ... }:

{

# Steam
programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    };


# Packages

environment.systemPackages = with pkgs; [


];

}
