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

    nix.package = pkgs.nixUnstable;
 
# Fonts
    fonts.packages = with pkgs; [
    cozette
    ];

# Packages to install on a system-wide level
    environment.systemPackages = with pkgs; [

# Editors
    vim
    #inkscape
    obs-studio
    #davinci-resolve


# Compilers
    #gcc
    python3

# Programs
    librewolf
    firefox
    brave
    mullvad
    mullvad-browser
    mullvad-vpn
    tor
    mpv

# Terminal stuff
    rsync 
    starship
    artem           #img-to-ascii
    cava
    porsmo          #pomodoro-timer
    #mop
    duf             #storage-visualizer
    #tgpt           #gpt chatbot
    du-dust         #better version of du
    tmux 
    zellij
    ripgrep
    #wiki-tui
    fzf 
    alacritty
    #kitty
    htop
    glances
    neofetch
    bunnyfetch 
    nitch
    cbonsai
    cmatrix
    ranger
    zoxide          #cd without amnesia
    joshuto         #ranger-like file manager written in rust
    figlet          #for outputting ascii-text in banners etc.
    ticker          #text-based price tracker
    tickrs          #visual price tracker
    eza             #better ls
    ttyper          #typing excercises
    dfrs            #df-replacement
    pipes-rs        #rust-written replacement
    #gurk-rs
    bat             #cat-replacement
    #ddgr
    #asciiquarium

# WM
    polybar
    rofi
    picom
    wpgtk
    pywal
    #themechanger
    #theme-sh
    imagemagick
    feh
    #eww
    #conky
    #dunst
    i3lock
    i3lock-fancy-rapid
    i3wsr
    #autorandr

# Tools
    dog             #replacecment for cat
    #proxychains-ng
    bandwhich       #bandwith tracker
    iw
    wirelesstools
    iftop           #top for network interfaces
    #youtube-tui
    #mage           #make-build tool written i Go
    #poetry          #python dependency management
    ngrok           #web server running on local machine
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
    nmon            #top-like tool
    zathura         #pdf-reader
    #xdotool
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
    #remmina        #rdp-interface
    xrdp            #rdp-interface
    warpd           #click stuff without mouse input
    ollama          #run llms locally
    aichat          #CLI gpt-chatbot 
    #llm-ls
    #llm
    unclutter       #hides mouse cursor when not in use
    unzip           #zip-archiving tool 
    tealdeer        #alternative to man
    lynis           #security auditing tool
    xrdp            #RDP-client
    udevil          #udisks replacement



/*
# Pentesting
    
    dirb            #web content scanner
    whatweb         #web scanning tool
    gobuster        #Web directory scanner        
    monsoon         #HTTP-enumerator
    #dirstalk
    feroxbuster     #dirbuster-alike tool
    
    dalfox          #XSS-scanner
    xsser           #XSS-scanner
    snmpcheck       #SNMP-enumerator

    enum4linux-ng   #SMB-scanner

   
    mitmproxy       #Man-in-the-middle Proxy
    burpsuite
    mitmproxy2swagger
    #caido          #Burpsuite-like tool
    #bettercap      #swiss army knife mitm-tool
    websploit       #MITM-framework

    
    openldap
    ldapdomaindump
    #bloodhound-py
    #bloodhound
    #autobloody     #automatically explioit AD privesc paths
    silenthound     #lightweight tool to enumerate AD enviroments

    responder
    #commix         #command injection exploitation tool
    #webanalyze     #similar to wapalyzer
    nikto           #scanner for website vulnerabilities
    nmap            #network-scanner
    rustscan        #nmap-alike tool written in rust
    
    #kismet         #wifi, bluetooth and RF-sniffer
    wireshark       #packet analysis and sniffer tool
    tcpdump         #network-sniffer
    tshark          #WireShark from the terminal
    #termshark
    crackmapexec    #tool for pentesting networks
    netexec
   
    uncover         #API wrapper to scan for exposed hosts(shodan-ish)
    sherlock        #OSINT username tracker
    theharvester    #OSINT recon tool
    
    dig             #domain name server 
    
    hydra-cli       #thc-hydra cli program
    thc-hydra       #network-logon cracker
    #medusa         #login brute-forcer
   
    hashcat         #password-cracker
    john            #password/hash-cracker
    seclists        #SecLists-implementation
    crunch          #Wordlist-generator
    #cewl           #wordlist-generation tool 
    metasploit      #All-in-one exploit tool
    sqlmap          #SQL Injection tool
    evil-winrm      #WinRM shell generator 

    ghost           #Android exploitation framework

    rustcat         #netcat-replacement written in rust
    #pwncat          #netcat with persistent shell
    
    bully           #WPA/WPA2 Password recovery from WPS-enabled access point
    cowpatty        #offline dictionary attack tool against WPA/WPA2-networks
    aircrack-ng
    airgeddon       #All-in-one network hacking tool
    wifite2         #TUI Wifi attack software
    mdk4            #injection tool for wireless networks
    hcxdumptool     #packet-capture tool from wlan devices
    hcxtools
    pixiewps        #ffline WPS Brute-forcing
    
    samba
    #awscli2
    exploitdb       #searchsploit
    redis
    mariadb
    
    
    wprecon         #WordPress vulnerability scanner
    wpscan
    
    routersploit    #embedded device exploitation framework
    
    #sleuthkit      #data recovery tool
    foremost        #file recovery tool
    testdisk        #data recovery tool

    
    dbmonster       #wifi-strength scanner
    linux-router    #wifi-hotspot/Proxy using a single command
    hostapd-mana    #rogue access point tool
    
    steghide        #extract data from images
    stegseek

    #parsero        #audit tool for robots.txt
    reaverwps       #wifi brute-forcing tool
    reaverwps-t6x
    dnsrecon        #DNS enumeration tool
    macchanger      #tool for spoofing MAC-address 
    dnsenum         #DNS enumeration tool
    fierce          #DNS enumeration tool
    
    wfuzz           #web fuzzing tool
    ffuf
*/
    
    
    
# X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    xorg.xmodmap
    
# Uncategorized
        ];
}
