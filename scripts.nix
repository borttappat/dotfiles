{ config, pkgs, ... }:

{
  # Your existing configuration settings
  
  environment.systemPackages = [
    # Any existing system packages
    
    # Importing and including your script from the dotfiles repository
   (import (pkgs.fetchFromGitHub {
      owner = "borttappat";
      repo = "dotfiles";
      rev = "main";  # Use the branch name
      sha256 = null; # Disable SHA256 hash checking

    }) {}).nixbuild
  ];
}

