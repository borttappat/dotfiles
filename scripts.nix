{ config, pkgs, ... }:

{

  
environment.systemPackages = [
    # Any existing system packages
    
# Importing and including your script
    (import /etc/nixos/nixbuild.nix {}).nixbuild
    ];

/*
dotfilesRepo = builtins.fetchGit {
    url = "https://github.com/borttappat/dotfiles.git";
    rev = "main";  # or specify a commit hash, tag, etc.
  };

  environment.shellInit = ''
    export PATH=$PATH:$dotfilesRepo/scripts/python:$dotfilesRepo/scripts/bash
  '';
*/

}

