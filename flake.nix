{
    description = "Griefhounds NixOS Flake for multiple devices";

        inputs = {

            #nixpkgs.url = "nixpkgs/nixos-unstable";
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
            #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
            #nixpkgs.url = "nixpkgs/nixos-git";
            
            
            #nix-index-database.url = "github:Mic92/nix-index-database";
            #nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
            };
            
          outputs = { self, nixpkgs, ... }@inputs:
    {
        nixosConfigurations = {
            
            "razer" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        #./modules/hardware-configuration.nix
                        ./modules/configuration.nix
                        #./modules/boot.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/nixp.nix
                        ./modules/users.nix
                        ./modules/hosts.nix
                        ./modules/razer.nix
                        ./modules/razerconf.nix
                        ./modules/colors.nix
                        ./modules/steam.nix
                        ./modules/pentesting.nix
                        ./modules/dev.nix
                        ./modules/scripts.nix
                         
                    ];
            };


           "WM" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/configuration.nix
                        ./modules/boot.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/nixp.nix
                        ./modules/users.nix
                        ./modules/colors.nix 
                    ];
            }; 


            "asus" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        #./modules/hardware-configuration.nix
                        ./modules/configuration.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/nixp.nix
                        ./modules/hosts.nix
                        ./modules/users.nix
                        ./modules/asus.nix
                        ./modules/asusconf.nix
                        ./modules/steam.nix
                        ./modules/colors.nix 
                        ./modules/pentesting.nix
                        #"/etc/nixos/hardware-configuration.nix"
                        ./modules/scripts.nix
                    ];
            };
            
            "default" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/hardware-configuration.nix
                        ./modules/configuration.nix
                        ./modules/boot.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/nixp.nix
                        ./modules/users.nix
                        ./modules/colors.nix
                        #"/etc/nixos/hardware-configuration.nix"
                        ./modules/scripts.nix
                    ];
            };

        };

    };
}
