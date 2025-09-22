{ config, pkgs, lib, ... }:

let
  # Build teamserver separately as a Go module
  havoc-teamserver = pkgs.buildGoModule rec {
    pname = "havoc-teamserver";
    version = "unstable-2024-01-01";

    src = pkgs.fetchFromGitHub {
      owner = "HavocFramework";
      repo = "Havoc";
      rev = "main";
      sha256 = "sha256-QU6frOXjNC6k/emSNVbYZwf0sg75vq40SRwkoEIlr5M=";
    };

    sourceRoot = "source/teamserver";
    vendorHash = "sha256-uxlZXqucTMavrtW5nB1P69XVu6668nh6k4S0BTiwgn4=";
    doCheck = false;

    buildInputs = with pkgs; [ openssl boost ];

    meta = with lib; {
      description = "Havoc C2 Framework Teamserver";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

  # Build client with ALL required dependencies
  havoc-client = pkgs.stdenv.mkDerivation rec {
    pname = "havoc-client";
    version = "unstable-2024-01-01";

    src = pkgs.fetchFromGitHub {
      owner = "HavocFramework";
      repo = "Havoc";
      rev = "main";
      sha256 = "sha256-QU6frOXjNC6k/emSNVbYZwf0sg75vq40SRwkoEIlr5M=";
    };

    sourceRoot = "source/client";

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      qt5.wrapQtAppsHook
      python3
      nasm
    ];

    buildInputs = with pkgs; [
      # Qt5 dependencies
      qt5.qtbase
      qt5.qttools
      qt5.qtwebsockets
      qt5.qtdeclarative

      # Graphics/GL
      libGL
      libGLU
      fontconfig
      freetype

      # Core libraries
      openssl
      zlib
      boost

      # X11
      xorg.libX11
      xorg.libXext
      xorg.libXrender

      # C++ libraries Havoc needs
      nlohmann_json
      spdlog
      toml11          # For toml.hpp
      gtest           # Google Test

      # Python
      python3
      python3Packages.pycryptodome
      python3Packages.requests
      python3Packages.websocket-client

      # Build essentials
      ncurses
      gdbm
      readline
      libffi
      sqlite
      bzip2
    ];

    configurePhase = ''
      runHook preConfigure
      mkdir -p Build
      cd Build
      cmake -DCMAKE_BUILD_TYPE=Release ..
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      make -j1
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp Havoc $out/bin/havoc-client
      runHook postInstall
    '';

    meta = with lib; {
      description = "Havoc C2 Framework Client";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

  # Create a wrapper package that combines both
  havoc = pkgs.symlinkJoin {
    name = "havoc";
    paths = [ havoc-teamserver havoc-client ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${havoc-client}/bin/havoc-client $out/bin/havoc \
        --run ${pkgs.writeShellScript "havoc-wrapper" ''
          case "$1" in
            client)
              shift
              exec ${havoc-client}/bin/havoc-client "$@"
              ;;
            teamserver|server)
              shift
              exec ${havoc-teamserver}/bin/havoc-teamserver "$@"
              ;;
            *)
              echo "Usage: havoc {client|teamserver|server} [options]"
              echo "  client      - Start Havoc client GUI"
              echo "  teamserver  - Start Havoc teamserver"
              echo "  server      - Alias for teamserver"
              exit 1
              ;;
          esac
        ''}
    '';
  };

in {
  environment.systemPackages = [
    havoc
    pkgs.wireshark
    pkgs.tcpdump
    pkgs.nmap
  ];

  # Open firewall ports for Havoc
  networking.firewall.allowedTCPPorts = [ 40056 ];
  networking.firewall.allowedUDPPorts = [ 40056 ];

  # Create havoc user and group for service
  users.users.havoc = {
    isSystemUser = true;
    group = "havoc";
    home = "/var/lib/havoc";
    createHome = true;
  };

  users.groups.havoc = {};

  # Create directories
  systemd.tmpfiles.rules = [
    "d /var/lib/havoc 0750 havoc havoc -"
    "d /var/log/havoc 0750 havoc havoc -"
  ];
}
