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
    [ 
      # Deprecated, have all been added to flake.nix. Saved for backup purposes
      #./hardware-configuration.nix
      #./packages.nix
      #./users.nix
      #./services.nix
    ];


# Modify the following like you would /etc/hosts
    networking.extraHosts =
    ''
    10.129.240.39 unika.htb
    10.129.72.251 thetoppers.htb
    10.129.72.251 s3.thetoppers.htb
    10.129.20.110 ignition.htb
    10.10.11.233 analytical.htb
    10.10.11.233 data.analytical.htb
    10.10.11.227 tickets.keeper.htb/rt/
    10.10.11.219 pilgrimage.htb
    10.10.11.221 2million.htb
    10.10.11.189 precious.htb
    
    '';

# Bootloader
    # SystemD-boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    
    # Grub
    #boot.loader.grub.enable = true;
    #boot.loader.grub.device = "/dev/vda";
    #boot.loader.grub.useOSProber = true;

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

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.traum = {
        isNormalUser = true;
        description = "A";
        extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
        packages = with pkgs; [
            ];
        };

# Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
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

# Configure keymap in X11
    services.xserver = {
        layout = "se";
        xkbVariant = "";
    };

system.stateVersion = "22.11"; 

}
