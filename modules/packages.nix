#                        __                                 _
#      ____  ____ ______/ /______ _____ ____  _____  ____  (_)  __
#     / __ \/ __ `/ ___/ //_/ __ `/ __ `/ _ \/ ___/ / __ \/ / |/_/
#    / /_/ / /_/ / /__/ ,< / /_/ / /_/ /  __(__  ) / / / / />  <
#   / .___/\__,_/\___/_/|_|\__,_/\__, /\___/____(_)_/ /_/_/_/|_|
#  /_/                          /____/

{ config, pkgs, ... }:

{

# Allowing unfree and unstable packages
    
# I'm sorry, Stallman
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;

    nix.package = pkgs.nixVersions.git;
 
# Fonts
    fonts.packages = with pkgs; [
    cozette
    #hack-font
    #creep
    ];

# Packages to install on a system-wide level
    environment.systemPackages = with pkgs; [

# Editors
    vim
    #inkscape
    #obs-studio
    #davinci-resolve


# Compilers
    gcc
    python3

# Programs
    #librewolf
    firefox
    brave
    mullvad
    mullvad-browser
    mullvad-vpn
    tor
    mpv

# Terminal stuff
    #tty-share       #
    tmate
    zsh
    rsync 
    starship
    #artem           #img-to-ascii
    cava
    #porsmo          #pomodoro-timer
    #mop
    #duf             #storage-visualizer
    #tgpt           #gpt chatbot
    du-dust         #better version of du
    tmux 
    #zellij
    #ripgrep
    ugrep
    #wiki-tui
    fzf 
    alacritty
    warp-terminal
    #kitty
    htop
    glances
    #neofetch
    fastfetch
    bunnyfetch 
    #nitch
    cbonsai
    cmatrix
    ranger
    zoxide          #cd without amnesia
    joshuto         #ranger-like file manager written in rust
    figlet          #for outputting ascii-text in banners etc.
    #ticker          #text-based price tracker
    #tickrs          #visual price tracker
    eza             #better ls
    ttyper          #typing excercises
    #dfrs            #df-replacement
    pipes-rs        #rust-written replacement
    #gurk-rs
    #bat             #cat-replacement
    #ddgr
    #asciiquarium

# WM
    polybar
    rofi
    picom
    #picom-pijulius
    #wpgtk
    pywal
    themix-gui
    #pywal16
    wallust
    #pywalfox-native
    #themechanger
    #theme-sh
    #imagemagick
    feh
    #eww
    #conky
    #dunst
    i3lock
    i3lock-fancy-rapid
    i3wsr
    #autorandr

# Tools
    #dog                    #replacecment for cat
    catppuccinifier-cli     #modify wallpapers with a catppucin style
    #proxychains-ng
    bandwhich           #bandwith tracker
    iw
    wirelesstools
    iftop           #top for network interfaces
    #youtube-tui
    #mage           #make-build tool written i Go
    #poetry          #python dependency management
    #ngrok           #web server running on local machine
    #pgrok          #similar to the above
    #tmate          #terminal-sharing
    #exiftool
    procs           #ps written in rust
    #bottles        #client for running windows-software
    gping           #graphical ping tool
    #openconnect
    openvpn         #openvpn-client
    brightnessctl   #brightness-handler
    #obsidian       #note taking tool
    light           #backlight-controller
    #undervolt
    git
    gh              #git CLI tool
    #nmon            #top-like tool
    zathura         #pdf-reader
    xdotool
    #jq
    killall 
    qemu 
    #kvmtool
    flameshot       #screenshot-tool
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
    docker          #added with virt.enable = true in services.nix
    lazydocker
    #signal-cli
    whois
    xrdp            #rdp-interface
    freerdp3
    warpd           #click stuff without mouse input
    ollama          #run llms locally
    #khoj
    aichat          #CLI gpt-chatbot 
    #llm-ls
    #llm
    unclutter       #hides mouse cursor when not in use
    unzip           #zip-archiving tool 
    tealdeer        #alternative to man
    lynis           #security auditing tool
    #udevil          #udisks replacement

    
# X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    xorg.xmodmap
    xorg.xmessage
    xorg.xcursorthemes
    
# Uncategorized
        ];
}
