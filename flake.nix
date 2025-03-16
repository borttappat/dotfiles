#     ___ __       __                   __
#   .'  _|  .---.-|  |--.-----.  .-----|__.--.--.
#   |   _|  |  _  |    <|  -__|__|     |  |_   _|
#   |__| |__|___._|__|__|_____|__|__|__|__|__.__|
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Function to make pkgs available
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Overlay to make unstable packages available
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

    in {
      
    devShells.${system} =
    let
        pkgs = pkgsForSystem system;
    in {
        bloodhound = (import ./modules/bloodhound.nix { inherit pkgs; }).devShells.bloodhound;
    };

    nixosConfigurations = {
        
        # Razer configuration
        razer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Base system configuration
            ./modules/configuration.nix
            
            # Device specific configurations
            ./modules/razer.nix
            ./modules/razerconf.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/boot.nix
            ./modules/zsh.nix
            ./modules/virt.nix
            ./modules/scripts.nix
            ./modules/nixi.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
          ];
        };

        # XMG Configuration
        xmg = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Base system configuration
            ./modules/configuration.nix
            
            # Device specific configurations
            ./modules/xmg.nix
            ./modules/xmgconf.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/zsh.nix
            ./modules/virt.nix
            ./modules/scripts.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/steam.nix
          ];
        };
        
        # ASUS configuration
        asus = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            
            # Device specific configurations
            ./modules/asus.nix
            ./modules/asusconf.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/zsh.nix
            #./modules/virt.nix
            ./modules/boot.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
          ];
        };

        # VM configuration
        VM = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/boot.nix
            ./modules/zsh.nix 

            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
          ];
        };

        # Default configuration
        default = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/boot.nix
            ./modules/zsh.nix
            ./modules/scripts.nix
          ];
        };
      };
    };
}
