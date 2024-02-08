{
    description = "Griefhounds NixOS Flake for multiple devices";

        inputs = {

            nixpkgs.url = "nixpkgs/nixos-unstable";
            
            nix-index-database.url = "github:Mic92/nix-index-database";
            nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
        };

    outputs = { self, nixpkgs, nix-index-database, ... }@inputs: {
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
                        #./scripts.nix
                        #nix-index-database.nixosModules.nix-index
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
                        ./hosts.nix
                    ];
            }; 


            "asus" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./hardware-configuration.nix
                        ./configuration.nix
                        ./boot.nix
                        ./packages.nix
                        ./services.nix
                        ./nixp.nix
                        ./hosts.nix
                        ./users.nix
                        ./asus.nix
                        ./steam.nix
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
                        ./hosts.nix
                    ];
            };

        };

    };
}
