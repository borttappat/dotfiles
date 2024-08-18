{ config, pkgs, ... }:

{


# Services

services.asusd.enable = true;


# Sound-extras
    
#services.pipewire.jack.enable = true;
#services.jack.jackd.enable = false;

services.asusd.enable = true;
# Packages

environment.systemPackages = with pkgs; [

#obinskit
asusctl
#bluez

];

}
