{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    nodePackages.npm
    postgresql
    python3Packages.virtualenv
  ];

  services.postgresql.enable = true;

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      spoils-online.local = {  # Use a local domain name for development
        enableACME = false;
        forceSSL = false;
        root = /var/www/spoils-online;  # Update this path
      };
    };
  };
}

