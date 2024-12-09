#       _   ___      ____  _____
#      / | / (_)  __/ __ \/ ___/
#     /  |/ / / |/_/ / / /\__ \
#    / /|  / />  </ /_/ /___/ /
#   /_/ |_/_/_/|_|\____//____/

{ config, pkgs, ... }:

{   

 # Enable hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

# Enable parallel startup of systemd services
 systemd = {
    services.nix-daemon.enable = true;
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

# Enable earlyoom to prevent system freezes
services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

boot = {
    # Reduce system shutdown timeout
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
    };
    
    # Enable CPU microcode updates
    loader.systemd-boot.enable = true;
    initrd.systemd.enable = true;
  };


# Enable zram for better memory management
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
    };

# CPU Frequency scaling
    services.thermald.enable = true;
        powerManagement = {
        enable = true;
        powertop.enable = true;
        cpuFreqGovernor = "ondemand";
    };

# Use binary cache for faster downloads
 nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

# Can't remember what this actually does but it has to do with colorschemes :)
    environment.variables = {
        BAT_THEME = "ansi";
    };

# Set PAM limits to allow avoid NixOS error with too many open files
security.pam.loginLimits = [
  {
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "4096";
  }
  {
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "8192";
  }
];


# WIP Sound settings
    hardware.enableAllFirmware = true;


# Allowing for flakes and nix-command 
    nix.settings.experimental-features = [ 
        "nix-command" 
        "flakes" 
        ];

# nix-ld, currently not used
    /*
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
    ];
    */


# Fish-shell
    programs.fish.enable=true;
    users.defaultUserShell = pkgs.fish;
    environment.shells = with pkgs; [ fish ];

#qt and gtk support
    qt = {
        enable = true;
        platformTheme = "gtk2";
        style = "adwaita-dark";
      };

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        gtk-engine-murrine
        gtk_engines
        gsettings-desktop-schemas
      ];

      environment.variables = {
        GTK_THEME = "Adwaita:dark";
      };

      environment.etc."gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=1
      '';

# Setting up for zsh
/*
programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        #theme = "robbyrussell";
        plugins = [
	  "git"
          "kubectl"
          "helm"
          "docker"
        ];
      };
    };
  };

  users.defaultUserShell = pkgs.zsh;
*/


# Kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

# Networking/Hostname, should be edited to conatin your hostname to build correctly with --flake/path/to/flake#hostname
    networking.hostName = "nix"; # Define your hostname.

# Enable networking
    networking.networkmanager.enable = true;

# Enable sound with pipewire
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
        extraGroups = [ "audio" "networkmanager" "wheel" "libvirtd" "wireshark" "adbusers" "docker" ];
        packages = with pkgs; [
            ];
        };

# Open ports in the firewall.
     networking.firewall.allowedTCPPorts = [ 21 25 80 110 135 139 389 445 587 1234 1433 3128 3141 8080 4444 4445 8000 53 3389 ];
     networking.firewall.allowedUDPPorts = [ 137 138 53 389 1434 5353 5355 5453 ];
    # Or disable the firewall altogether.
     networking.firewall.enable = false;
     networking.nftables.enable = false;

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
    services.xserver.xkb = {
        layout = "se";
        variant = "";
    };
    
# Automatic gargabe collection
/*    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 10d";
    };
*/

# Automatic nix-store optimizing
    nix.settings.auto-optimise-store = true;


system.stateVersion = "22.11"; 

}
