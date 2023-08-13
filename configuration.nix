#       _   ___      ____  _____
#      / | / (_)  __/ __ \/ ___/
#     /  |/ / / |/_/ / / /\__ \
#    / /|  / />  </ /_/ /___/ /
#   /_/ |_/_/_/|_|\____//____/

#NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{   
      
# Allowing for flakes and nix-command 
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./services.nix
    ];

# Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";

    # OpenGL
    # hardware.opengl.extraPackage = with pkgs; [ intel-media-driver intel-ocl vaapiIntel ];
    
    # Video acceleration
    boot.kernelParams = [ "i915.force_probe=9a49" ];
    
# Networking/Hostname
    networking.hostName = "nix"; # Define your hostname.
    
# Enables wireless support via wpa_supplicant
    #networking.wireless.enable = true;  

# Enable networking
    networking.networkmanager.enable = true;

# Enable sound with pipewire
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
    };

##############
#  Firewall  #
##############

# Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

  
###########
#  Misc   #
###########

# Enable Automatic Upgrades
    system.autoUpgrade.enable = true;
# Do not allow for automatic reboots
    # system.autoUpgrade.allowReboot = true;

# Enable i2c-bus
    hardware.i2c.enable = true;

# Enable Flatpak
    #xdg.portal.enable = true; # only needed if you are not doing Gnome
    #services.flatpak.enable = true;  
    # Run this command to add flathub
    # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo  

# Setup NUR
    #nixpkgs.config.packageOverrides = pkgs: {
    #nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        #inherit pkgs;
        #};
    #};

system.stateVersion = "22.11"; 

}
