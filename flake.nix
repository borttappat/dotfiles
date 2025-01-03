#     ___ __       __                   __
#   .'  _|  .---.-|  |--.-----.  .-----|__.--.--.
#   |   _|  |  _  |    <|  -__|__|     |  |_   _|
#   |__| |__|___._|__|__|_____|__|__|__|__|__.__|

{

nixConfig = {
        #allow-dirty = true;
        #warn-dirty = false;
        #trusted-users = [ "root" "traum" ];
        accept-flake-config = true;
        experimental-features = [ "nix-command" "flakes" ];
    };

description = "Griefhounds NixOS Flake for multiple devices";
        
    inputs = {

        nixpkgs.url = "nixpkgs/nixos-unstable";
        #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        #nixpkgs.url = "nixpkgs/nixos-git";
        
        
        #nix-index-database.url = "github:Mic92/nix-index-database";
        #nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
        };
            
    outputs = { self, nixpkgs, ... }@inputs:
        {
        nixosConfigurations = {
            # razer-machine, set up with most modules enabled. Considered to be "main" machine            
            "razer" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/configuration.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/users.nix
                        ./modules/hosts.nix
                        ./modules/razer.nix
                        ./modules/razerconf.nix
                        ./modules/colors.nix
                        ./modules/steam.nix
                        ./modules/pentesting.nix
                        #./modules/dev.nix
                        ./modules/zsh.nix
                        ./modules/proxychains.nix
                        ./modules/scripts.nix
                         
                    ];
            };

            # VM, set up as a slightly lighter version without pentesting tools, steam, etc.
            "VM" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/configuration.nix
                        ./modules/boot.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/users.nix
                        ./modules/colors.nix 
                        ./modules/scripts.nix
                    ];
            }; 

            # Asus laptop, set up similar to razer or "main"machine
            "asus" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/configuration.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/hosts.nix
                        ./modules/users.nix
                        ./modules/asus.nix
                        ./modules/asusconf.nix
                        ./modules/steam.nix
                        ./modules/colors.nix 
                        ./modules/pentesting.nix
                        ./modules/scripts.nix
                    ];
            };
            # default or fall-back option for when the build script does not recognize KVM/QEMU, Razer or Asus hardware 
            "default" = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                    modules = [
                        ./modules/hardware-configuration.nix
                        ./modules/configuration.nix
                        ./modules/boot.nix
                        ./modules/packages.nix
                        ./modules/services.nix
                        ./modules/users.nix
                        ./modules/colors.nix
                        ./modules/scripts.nix
                    ];
            };
        };
    };
}
