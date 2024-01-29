{
    description = "Griefhounds NixOS Flake for multiple devices";

        inputs = {

            nixpkgs.url = "nixpkgs/nixos-unstable";
            
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

        };

    };
}
