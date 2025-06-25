#                    __                                     __
#  .-----.---.-.----|  |--.---.-.-----.-----.-----.  .-----|__.--.--.
#  |  _  |  _  |  __|    <|  _  |  _  |  -__|__ --|__|     |  |_   _|
#  |   __|___._|____|__|__|___._|___  |_____|_____|__|__|__|__|__.__|
#  |__|                         |_____|

{ config, pkgs, ... }:

{

# Editor-settings
environment.variables = {
  EDITOR = "vim";
  VISUAL = "vim";
};

nixpkgs.config.packageOverrides = pkgs: {
  librewolf = pkgs.librewolf.override {
    extraPrefs = ''
      pref("browser.startup.homepage", "https://borttappat.github.io/links.html");
      pref("browser.newtab.url", "https://borttappat.github.io/links.html");
      pref("browser.newtabpage.enabled", true);
      pref("browser.newtab.preload", true);
      pref("browser.newtabpage.enhanced", true);
      pref("browser.newtabpage.activity-stream.showSearch", true);
      pref("browser.newtabpage.activity-stream.default.sites", "");
    '';
  };
  
  firefox = pkgs.firefox.override {
    extraPrefs = ''
      pref("browser.startup.homepage", "https://borttappat.github.io/links.html");
      pref("browser.newtab.url", "https://borttappat.github.io/links.html");
      pref("browser.newtabpage.enabled", true);
      pref("browser.newtab.preload", true);
      pref("browser.newtabpage.enhanced", true);
      pref("browser.newtabpage.activity-stream.showSearch", true);
      pref("browser.newtabpage.activity-stream.default.sites", "");
    '';
  };
};

# Allowing unfree and unstable packages
# I'm sorry, Stallman
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;

    nix.package = pkgs.nixVersions.git;
 
# Fonts
    fonts.packages = with pkgs; [
    cozette
    hack-font
    creep
    ];

# Packages to install on a system-wide level
    environment.systemPackages = with pkgs; [

     (writeShellScriptBin "burp" ''
    ${burpsuite}/bin/burpsuite --project-file=memory:// --user-config-file=memory://
  '')

# Editors
    vim
    #neovim
    #helix
    #inkscape
    #obs-studio
    #davinci-resolve

# Compilers
    gcc
    python3
    jython

# Programs
    krita
    librewolf
    firefox
    #brave
    #ungoogled-chromium
    mullvad
    #nyxt
    #qutebrowser
    #mullvad-browser
    mullvad-vpn
    #tor
    mpv
    #pipewire

# Terminal stuff
    tmate
    zsh
    rsync 
    starship
    artem           #img-to-ascii
    cava
    #mop
    du-dust         #better version of du
    tmux 
    #zellij
    #ripgrep
    ugrep
    #wiki-tui
    fzf 
    alacritty
    ghostty
    warp-terminal
    thefuck         #Magnificent app which corrects your previous console command
    #kitty
    htop
    #glances
    bottom          # visual process monitor
    #neofetch
    fastfetch
    #bunnyfetch 
    #nitch
    cbonsai         # cli-gardening
    cmatrix         # follow the white rabbit
    ranger
    zoxide          #cd without amnesia, sourced in config.fish
    blesh           #Bash Line Editor
    joshuto         #ranger-like file manager written in rust
    figlet          #for outputting ascii-text in banners etc.
    #ticker          #text-based price tracker
    #tickrs          #visual price tracker
    eza             #better ls
    ttyper          #typing excercises
    pipes-rs        #rust-written replacement
    #gurk-rs
    #ddgr
    bat

# WM
    polybar
    rofi
    picom
    #picom-pijulius
    wpgtk
    pywal
    themix-gui
    wallust
    pywalfox-native
    themechanger
    #theme-sh
    imagemagick
    feh
    #eww
    #conky
    #dunst
    scrot
    flameshot
    i3lock-color
    i3lock-fancy
    #i3lock-fancy-rapid
    #i3wsr
    #autorandr

# Tools
    #dog                    #replacecment for cat
    alsa-utils
    #catppuccinifier-cli     #modify wallpapers with a catppucin style
    bandwhich           #bandwith tracker
    iw
    wirelesstools
    #youtube-tui
    ngrok           #web server running on local machine
    #pgrok          #similar to the above
    procs           #ps written in rust
    #bottles        #client for running windows-software
    gping           #graphical ping tool
    openvpn         #openvpn-client
    brightnessctl   #brightness-handler
    obsidian        #note taking tool
    notesnook       #OS-alternative to obsidian
    #light           #backlight-controller
    #undervolt
    git
    gh              #git CLI tool
    zathura         #pdf-reader
    xdotool
    #jq
    killall 
    rar             #RAR-archive tool
    pciutils
    curl
    wget
    lshw
    toybox
    findutils
    busybox
    inetutils
    udisks
    
    ansible         #we be devs now
    
    signal-cli
    whois
    warpd           #click stuff without mouse input
    ollama          #run llms locally
    gpt4all
    local-ai
    #khoj
    aichat          #CLI gpt-chatbot 
    unclutter       #hides mouse cursor when not in use
    unzip           #zip-archiving tool 
    tealdeer        #alternative to man
    #udevil          #udisks replacement
    jq              #JSON processor

    
# X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    xorg.xmodmap
    xorg.xmessage
    xorg.xcursorthemes
    


# Uncategorized
    pulseaudioFull
        ];
}
