{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Build tools
    gnumake cmake pkg-config gcc git
    
    # Qt5 dependencies 
    qt5.qtbase qt5.qttools qt5.qtwebsockets qt5.qtdeclarative libsForQt5.full
    
    # Languages
    python3 go
    
    # Libraries
    openssl zlib boost libGL libGLU fontconfig freetype
    xorg.libX11 xorg.libXext xorg.libXrender
    ncurses gdbm readline libffi sqlite bzip2 nasm
    
    # Python packages
    python3Packages.pycryptodome
    python3Packages.requests
    python3Packages.websocket-client
    
    # Pentesting tools
    wireshark tcpdump nmap
  ];

  # Open firewall for Havoc
  # networking.firewall.allowedTCPPorts = [ 40056 ];
  # networking.firewall.allowedUDPPorts = [ 40056 ];
}
