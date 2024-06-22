{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    python312
    python312Packages.flask
    nodejs
    git
    #vscode
    curl
    wget
  ];

  networking.firewall = {
    allowedTCPPorts = [ 
      5000  # Flask backend
      5173  # Vue.js development server (default port)
    ];
  };
}
