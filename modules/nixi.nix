# ~/dotfiles/modules/nixi.nix
{ config, pkgs, lib, ... }:

let
  nixi = pkgs.python3Packages.buildPythonApplication {
    pname = "nixi";
    version = "0.1.0";
    
    src = ../tools/nixi;  # Points to the directory containing nixi.py
    
    propagatedBuildInputs = with pkgs.python3Packages; [
      requests
      configparser
    ];
    
    doCheck = false;
    
    installPhase = ''
      mkdir -p $out/bin
      cp nixi.py $out/bin/nixi
      chmod +x $out/bin/nixi
    '';
  };
in
{
  environment.systemPackages = [ nixi ];
  
  # Ensure required dependencies are available
  environment.systemPackages = with pkgs; [
    ollama  # For local model support
    python3
    python3Packages.requests
    python3Packages.configparser
  ];
}
