{ config, pkgs, lib, ... }:

{
  # Import your existing boot.nix (which will be populated by nixsetup.sh)
  networking.hostName = "nixos-arm";
  networking.networkmanager.enable = true;


    # Enable Docker
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      # Ensure compatibility with ARM
      extraOptions = "--add-runtime=crun=/run/current-system/sw/bin/crun";
      daemon.settings = {
        experimental = true;
        "exec-opts" = ["native.cgroupdriver=systemd"];
      };
    };
  };


  # Ensure the service is created and enabled
  systemd.services.docker = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
    };
  };



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
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;

  # Define user account
  users.users.traum = {
    isNormalUser = true;
    description = "Traum";
    extraGroups = [ "audio" "networkmanager" "wheel" "docker" ];
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

  # Editor-settings
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Essential packages
  environment.systemPackages = with pkgs; [
    # WM and desktop environment
    i3-gaps
    polybar
    rofi
    feh
    picom
    #i3lock-color
    #i3lock-fancy
    dunst
    pywal
    pywalfox-native
    jq
    flameshot
    docker
    
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
    tmux

    xorg.xev
    
    # Development tools
    vim
    git
    gh
    curl
    wget
    python3
    
    # Applications
    zathura
    firefox
    obsidian
    
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

    # Docker-shit
    docker-compose
    docker-client
    crun # Container runtime for better ARM support


  ];

  fonts.packages = with pkgs; [
    cozette
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
