{ config, pkgs, lib, ... }:

{
  
environment.systemPackages = with pkgs; [
    python312
    python312Packages.flask
    python312Packages.pip
    python312Packages.flask-cors
    python312Packages.flask-socketio

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
