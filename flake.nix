{
    description = "Griefhounds NixOS Flake for multiple devices";

        inputs = {

            #nixpkgs.url = "nixpkgs/nixos-unstable";
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
            #nixpkgs.url = "nixpkgs/nixos-git";
            
            
            #nix-index-database.url = "github:Mic92/nix-index-database";
            #nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
        };

    outputs = { self, nixpkgs, ... }@inputs: {
        nixosConfigurations = {
            
            "razer" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./hardware-configuration.nix
                        ./configuration.nix
                        ./boot.nix
                        ./packages.nix
                        ./services.nix
                        ./nixp.nix
                        ./users.nix
                        ./hosts.nix
                        ./razer.nix
                        ./razerconf.nix
                        ./colors.nix
                        #./nixbuild.nix
                        #./scripts.nix
                        #nix-index-database.nixosModules.nix-index
                        ./steam.nix
                        ./pentesting.nix
                        ./dev.nix
                    ];
            };


           "WM" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./hardware-configuration.nix
                        ./configuration.nix
                        ./boot.nix
                        ./packages.nix
                        ./services.nix
                        ./nixp.nix
                        ./users.nix
                        ./colors.nix 
                    ];
            }; 


            "asus" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        #./hardware-configuration.nix
                        ./configuration.nix
                        ./packages.nix
                        ./services.nix
                        ./nixp.nix
                        ./hosts.nix
                        ./users.nix
                        ./asus.nix
                        ./asusconf.nix
                        ./steam.nix
                        ./colors.nix 
                        ./pentesting.nix
                    ];
            };
            
            "default" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./hardware-configuration.nix
                        ./configuration.nix
                        ./boot.nix
                        ./packages.nix
                        ./services.nix
                        ./nixp.nix
                        ./users.nix
                        ./colors.nix
                    ];
            };

        };

    };
}
