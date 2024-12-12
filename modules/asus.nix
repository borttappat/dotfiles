{ config, pkgs, ... }:

{


# Services
services.asusd.enable = true;

# Sound-extras
#services.pipewire.jack.enable = true;
#services.jack.jackd.enable = false;

# Packages
environment.systemPackages = with pkgs; [

#obinskit
asusctl
#bluez

];

}
