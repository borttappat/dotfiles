bash -c 'cat > ~/dotfiles/modules/havoc.nix << '\''EOF'\''
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Build tools
    gnumake cmake pkg-config gcc git
    
    # Qt5 dependencies (required for client)
    qt5.qtbase
    qt5.qttools
    qt5.qtwebsockets
    qt5.qtdeclarative
    
    # Python (required by client build)
    python3
    python3Packages.pycryptodome
    python3Packages.requests
    python3Packages.websocket-client
    
    # Go (required for teamserver) 
    go
    
    # System libraries
    openssl zlib boost
    libGL libGLU fontconfig freetype
    xorg.libX11 xorg.libXext xorg.libXrender
    ncurses gdbm readline libffi sqlite bzip2
    
    # Assembly tools
    nasm
    
    # Additional C++ libraries (included as submodules, but good to have)
    nlohmann_json spdlog toml11 gtest
    
    # Pentesting companion tools
    wireshark tcpdump nmap
  ];

  # Open firewall ports for Havoc C2
  networking.firewall.allowedTCPPorts = [ 40056 ];
  networking.firewall.allowedUDPPorts = [ 40056 ];

  # Create havoc user for service (optional)
  users.users.havoc = {
    isSystemUser = true;
    group = "havoc"; 
    home = "/var/lib/havoc";
    createHome = true;
  };

  users.groups.havoc = {};

  systemd.tmpfiles.rules = [
    "d /var/lib/havoc 0750 havoc havoc -"
  ];

  # Note: To build Havoc manually:
  # 1. git clone https://github.com/HavocFramework/Havoc.git ~/havoc
  # 2. cd ~/havoc && make ts-build  
  # 3. cd ~/havoc && nix-shell -p qt5.qtbase qt5.qttools qt5.qtwebsockets qt5.qtdeclarative cmake pkg-config python3 --run "make client-build"
  # 4. Binaries will be at: ~/havoc/havoc (teamserver) and ~/havoc/client/Havoc (client)
}
EOF'
