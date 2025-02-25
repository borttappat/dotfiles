#     ___ __       __                   __
#   .'  _|  .---.-|  |--.-----.  .-----|__.--.--.
#   |   _|  |  _  |    <|  -__|__|     |  |_   _|
#   |__| |__|___._|__|__|_____|__|__|__|__|__.__|
{
  description = "NixOS configurations with modular design";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Additional inputs could go here
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      # System architecture
      system = "x86_64-linux";
      
      # Function to make pkgs available
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
      # Overlay for unstable packages
      overlays = {
        default = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        
        # Add additional overlays as needed
      };
      
      # Helper function to build a NixOS system with common configuration
      mkSystem = { hostName, modules ? [], extraModules ? [] }: 
        nixpkgs.lib.nixosSystem {
          inherit system;
          
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlays
            { nixpkgs.overlays = [ overlays.default ]; }
            
            # Core modules - common to all systems
            ./modules/configuration.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/boot.nix
            ./modules/zsh.nix
            ./modules/scripts.nix
          ] 
          ++ modules     # Host-specific modules
          ++ extraModules; # Additional feature modules
        };

    in {
      nixosConfigurations = {
        # Razer configuration
        razer = mkSystem {
          hostName = "razer";
          modules = [
            ./modules/razer.nix
            ./modules/razerconf.nix
            ./modules/virt.nix
            ./modules/nixi.nix
          ];
          extraModules = [
            ./modules/pentesting.nix
            ./modules/proxychains.nix 
            ./modules/dev.nix
            ./modules/steam.nix
          ];
        };
        
        # XMG Configuration
        xmg = mkSystem {
          hostName = "xmg";
          modules = [
            ./modules/xmg.nix
            ./modules/xmgconf.nix
          ];
          extraModules = [
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/steam.nix
          ];
        };
        
        # ASUS configuration
        asus = mkSystem {
          hostName = "asus";
          modules = [
            ./modules/asus.nix
            ./modules/asusconf.nix
            ./modules/virt.nix
          ];
          extraModules = [
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
          ];
        };
        
        # VM configuration
        VM = mkSystem {
          hostName = "vm";
          modules = [];
          extraModules = [
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
          ];
        };
        
        # Default configuration
        default = mkSystem {
          hostName = "nixos";
          modules = [];
          extraModules = [];
        };
      };
      
      # Development shells
      devShells.${system} = 
        let
          pkgs = pkgsFor system;
        in {
          bloodhound = import ./modules/bloodhound.nix { inherit pkgs; };
          # Add more development shells as needed
        };
    };
}
