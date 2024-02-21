#       _   ___      ____  _____
#      / | / (_)  __/ __ \/ ___/
#     /  |/ / / |/_/ / / /\__ \
#    / /|  / />  </ /_/ /___/ /
#   /_/ |_/_/_/|_|\____//____/


{ config, pkgs, ... }:

{   
      
# Allowing for flakes and nix-command 
    nix.settings.experimental-features = [ 
        "nix-command" 
        "flakes" 
        ];
    
# Nix-scripts, WIP

/*
environment.systemPackages = [
    (import /.nixbuild.nix { inherit pkgs; })
    ];
*/

/*
let
    nixbuild = import ./nixbuild.nix { inherit pkgs; };
in
{
    environment.systemPackagess = [
        nixbuild
    ];
};



*/


# Kernel
     boot.kernelPackages = pkgs.linuxPackages_latest;

# Networking/Hostname
    networking.hostName = "nix"; # Define your hostname.

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

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.traum = {
        isNormalUser = true;
        description = "A";
        extraGroups = [ "networkmanager" "wheel" "libvirtd" "wireshark" ];
        packages = with pkgs; [
            ];
        };

# Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ 53 80 443 1401];
    # networking.firewall.allowedUDPPorts = [ 53 1194 1195 1197 1300 1301 1302 1303 1400 ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

# Time zone
    time.timeZone = "Europe/Stockholm";

# Locale settings
    i18n.defaultLocale = "en_US.UTF-8";
    
    i18n.extraLocaleSettings = {
        LC_ADDRESS = "sv_SE.UTF-8";
        LC_IDENTIFICATION = "sv_SE.UTF-8";
        LC_MEASUREMENT = "sv_SE.UTF-8";
        LC_MONETARY = "sv_SE.UTF-8";
        LC_NAME = "sv_SE.UTF-8";
        LC_NUMERIC = "sv_SE.UTF-8";
        LC_PAPER = "sv_SE.UTF-8";
        LC_TELEPHONE = "sv_SE.UTF-8";
        LC_TIME = "sv_SE.UTF-8";
    };

# Configure console keymap
    console.keyMap = "sv-latin1";


# Enable the X11 windowing system
    services.xserver.enable = true;

# Window- and Display-manager settings
    services.xserver.displayManager.startx.enable = true;
    services.xserver.windowManager.i3.enable = true;
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

# Configure keymap in X11
    services.xserver = {
        layout = "se";
        xkbVariant = "";
    };
    
# Automatic gargabe collection
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 10d";
    };

# Automatic nix-store optimizing
    nix.settings.auto-optimise-store = true;


system.stateVersion = "22.11"; 

}
