# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{   
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;
      

 # allowing for flakes and nix-command 
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Enable the GNOME Desktop Environment.
  #  services.xserver.displayManager.gdm.enable = true;
  #  services.xserver.desktopManager.gnome.enable = true;

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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    #pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

  };

  # Enable touchpad support (enabled default in most desktopManager).
   services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.traum = {
    isNormalUser = true;
    description = "A";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #firefox
      
    ];
  };


  # Removing need for user traum to type password after sudo
  security.sudo.extraRules= [
   {  users = [ "traum" ];
     commands = [
        { command = "ALL" ;
          options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
       }
     ];
   }
 ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   # Editors
    vim
    # neovim
    
   # Compilers
    # gcc
    #python3

   # Programs
    librewolf
    
   # Terminal stuff
    alacritty
    htop
    glances
    fish
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
    wpgtk
    pywal
    feh
    #eww
    
   # Tools
    brightnessctl
    light 
    #auto-cpufreq
    #pciutils
    #cpufrequtils
    undervolt
    git
    tlp
    # iftop
    chatgpt-cli
    nmon
    zathura
    xdotool
    killall

   # X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    
   # Uncategorized
    unclutter
    #nixos-grub2-theme
    
  ];
  
   programs.fish.enable=true;
   users.defaultUserShell = pkgs.fish;

    services.xserver.windowManager.i3.package = pkgs.i3-gaps; 	   
  #  services.xserver.windowManager.i3.package = pkgs.i3-rounded;
  
  # Enabling TLP
   services.tlp.enable = true;
 
  # Enabling auto-cpufreq
  # services.autocpuFreq = {
  #    enable = true;
  #    governor = "powersave";
  #    frequency = "33%";
  #  };;

  # Some programs need SUID wrappers, can be configured further or are
  
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable Automatic Upgrades
  system.autoUpgrade.enable = true;
  
  # Do not allow for automatic reboots
  # system.autoUpgrade.allowReboot = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
