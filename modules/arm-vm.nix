{ config, pkgs, lib, ... }:

{
  # Import your existing boot.nix (which will be populated by nixsetup.sh)
  imports = [ 
    ./modules/boot.nix
  ];

  # Basic networking
  networking.hostName = "nixos-arm";
  networking.networkmanager.enable = true;

  # Set your time zone
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

  # Enable X11 with i3
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    windowManager.i3.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "se";
      variant = "";
    };
    
    # Virtual environment-friendly video driver
    videoDrivers = [ "modesetting" "fbdev" ];
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define user account
  users.users.traum = {
    isNormalUser = true;
    description = "Traum";
    extraGroups = [ "audio" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # No password sudo for user
  security.sudo.extraRules = [
    { users = [ "traum" ];
      commands = [
        { command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Essential packages
  environment.systemPackages = with pkgs; [
    # WM and desktop environment
    i3-gaps
    polybar
    rofi
    feh
    picom
    i3lock-color
    i3lock-fancy
    dunst
    pywal
    pywalfox
    
    # Terminal and tools
    alacritty
    zsh
    starship
    ranger
    joshuto
    fastfetch
    htop
    bottom
    cbonsai
    cmatrix
    pipes-rs
    zoxide
    eza
    bat
    
    # Development tools
    vim
    git
    curl
    wget
    
    # Applications
    zathura
    firefox
    
    # System tools
    blesh
    unzip
    killall
    brightnessctl
    
    # Media
    mpv
    
    # Networking tools
    networkmanager
    
    # Fonts
    cozette
    
    # Additional utilities
    ugrep
    figlet
  ];

  # Basic services
  services = {
    openssh.enable = true;
    udisks2.enable = true;
    libinput.enable = true;
  };

  # Enable ZSH
  programs.zsh.enable = true;

  # System version
  system.stateVersion = "23.11";
}
