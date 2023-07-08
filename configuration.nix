#####################
#   NixOS Config    #
#####################


#NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Allowing unfree andn unstable packages
{   
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;
      

# Allowing for flakes and nix-command 
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";

# Enabling i2c for intel-related things
#    hardware.i2c.enable = true;
#    services.hardware.openrgb.motherboard = intel;

# Networking/Hostname
    networking.hostName = "nix"; # Define your hostname.
    
    # Enables wireless support via wpa_supplicant
    #networking.wireless.enable = true;  

# Enable networking
    networking.networkmanager.enable = true;

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

# Enable the X11 windowing system
    services.xserver.enable = true;
  
# Enable the GNOME Desktop Environment
    #services.xserver.displayManager.gdm.enable = true;
    #services.xserver.desktopManager.gnome.enable = true;

# Window- and Display-manager settings
    services.xserver.displayManager.startx.enable = true;
    services.xserver.windowManager.i3.enable = true;

# Configure keymap in X11
    services.xserver = {
        layout = "se";
        xkbVariant = "";
    };

# Configure console keymap
  console.keyMap = "sv-latin1";

# Enable sound with pipewire
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
    };

# Enable touchpad support
    services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.traum = {
        isNormalUser = true;
        description = "A";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };


# Removing need for user "traum" to type password after sudo
    security.sudo.extraRules= [
    {users = [ "traum" ];
        commands = [
            { command = "ALL" ;
          options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
            }
            ];
    }
    ];

# Fonts 
    fonts.fonts = with pkgs; [
    nerdfonts
    ];

############
# Packages #
############
  environment.systemPackages = with pkgs; [

# Editors
    vim
    
# Compilers
    #gcc
    python3

# Programs
    librewolf
    brave
    #mullvad-browser
    tor

# Terminal stuff
    alacritty
    htop
    glances
    neofetch
    bunnyfetch
    pfetch
    nitch
    cbonsai
    cmatrix
    ranger

# WM
    i3-gaps
    polybar
    rofi
    picom
    #wpgtk
    pywal
    feh
    #eww
    #conky
    betterlockscreen
    i3lock-color
    #i3lock
    #i3lock-fancy

# Tools
    brightnessctl
    light 
    #pciutils
    undervolt
    git
    gh
    chatgpt-cli
    nmon
    zathura
    xdotool
    killall
    qemu
    #kvmtool
    tmux    
    onionshare
    #picosnitch
    flameshot
    rar

    wifite2
    iw
    wirelesstools
    hydra-cli
    thc-hydra
    theharvester
    nmap
    dirb
    wireshark
    medusa
    metasploit
    libargon2
    kismet
    airgeddon
    steghide
    stegseek
    parsero
    commix
    cewl
    bettercap
    whatweb
    python311Packages.scapy
    reaverwps
    reaverwps-t6x
    john
    netdiscover
    lynis
    fcrackzip
    dnsrecon
    socat
    macchanger
    httrack
    ghidra
    foremost
    dnsenum
    fierce
    cryptsetup
    aircrack-ng
    wfuzz
    testdisk
    sqlmap
    wpscan
    hashcat
    tcpdump
    ettercap
    masscan
    sherlock
    fping
    evil-winrm
    python311Packages.pypykatz
    driftnet    

# X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    
# Uncategorized
    unclutter
    unzip
    tealdeer
];
   
   
#########################
# Programs and services #
#########################

# Asusd
#    services.asusd.enable = true; 
   
# Fish-shell
    programs.fish.enable=true;
    users.defaultUserShell = pkgs.fish;
   
# i3-lock
    programs.i3lock.enable=true;
   
# Window-manager
    services.xserver.windowManager.i3.package = pkgs.i3-gaps; 	   
    #services.xserver.windowManager.i3.package = pkgs.i3-rounded;
  
# Enabling TLP
# TLP fucking sucks, don't use it. Instead, use auto-cpufreq below
    #services.tlp.enable = true;
 
# Enabling auto-cpufreq
    services.auto-cpufreq.enable = true;

# Intel-undervolt
    #services.undervolt.enable = true;

# Enable the OpenSSH daemon.
    services.openssh.enable = true;

# Enabling tailscale VPN
    services.tailscale.enable = true;

# Enabling OpenRGB
    services.hardware.openrgb.enable = true;

  
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

# Some programs need SUID wrappers, can be configured further or are
  
    #started in user sessions.
    #programs.mtr.enable = true;
    #programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    #};



system.stateVersion = "22.11"; # Did you read the comment?

}
