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

#services.xserver.videoDrivers = [ "intel" ];
#boot.kernelParams = [ "i915.force_probe=9a49" ];

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
    ];


# Fish-shell
    programs.fish.enable=true;
    users.defaultUserShell = pkgs.fish;
    environment.shells = with pkgs; [ fish ];

 qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
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
#programs.dconf.enable = true;

# Kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

# Networking/Hostname, should be edited to conatin your hostname to build correctly with --flake/path/to/flake#hostname
    networking.hostName = "nix"; # Define your hostname.

# Enable networking
    networking.networkmanager.enable = true;

# Enable sound with pipewire
    #sound.enable = true;
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
     networking.firewall.allowedTCPPorts = [ 1234 8080 4444 4445 8000 53 3389];
     networking.firewall.allowedUDPPorts = [ 5355 5453 ];
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
    services.xserver.xkb = {
        layout = "se";
        variant = "";
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
