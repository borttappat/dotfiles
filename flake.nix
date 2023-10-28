{
    description = "griefhounds NixOS flake";
    
    inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #nixos-hardware.url = "github:nixos/nixos-hardware";

    #nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    };
    
    outputs = { self, nixpkgs }:
        let
            user = "traum";
            system = "x86_64-linux";
            
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                };
            
            lib = nixpkgs.lib;
        in {

            nixosConfigurations = { 
                ${user} = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = {inherit user;};
                    modules = [ 
                        ./configuration.nix
                        ./hardware-configuration.nix 
                        ./packages.nix
                        ./services.nix
                        ./users.nix
                        #./nixp.nix

                    ]; 
                    };
                };
        };
}

