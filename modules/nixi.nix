# ~/dotfiles/modules/nixi.nix
{ config, pkgs, lib, ... }:

let
  nixi = pkgs.stdenv.mkDerivation {
    pname = "nixi";
    version = "0.1.0";
    
    src = ../tools/nixi;  # Directory containing nixi.py
    
    # Specify the runtime dependencies that nixi needs
    nativeBuildInputs = [ pkgs.makeWrapper ];
    
    buildInputs = with pkgs; [
      python3
      python3Packages.requests
      python3Packages.configparser
    ];
    
    # Simple installation phase that copies our script and sets up dependencies
    installPhase = ''
      # Create the bin directory
      mkdir -p $out/bin
      
      # Copy our script
      cp nixi.py $out/bin/nixi
      
      # Make it executable
      chmod +x $out/bin/nixi
      
      # Wrap the script with its Python dependencies
      wrapProgram $out/bin/nixi \
        --prefix PYTHONPATH : "${pkgs.python3.withPackages (ps: with ps; [
          requests
          configparser
        ])}/lib/python${pkgs.python3.pythonVersion}/site-packages"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    nixi
    ollama
  ];
}
