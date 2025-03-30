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
      # Define supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Function to make pkgs available for different architectures
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Function to get pkgs for a specific system
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Overlay to make unstable packages available
      overlay-unstable = system: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

    in {
      
    devShells = forAllSystems (system: let
        pkgs = pkgsForSystem system;
    in {
        bloodhound = (import ./modules/bloodhound.nix { inherit pkgs; }).devShells.bloodhound;
    });

    nixosConfigurations = {
        
        # ARM VM configuration
        armVM = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ (overlay-unstable "aarch64-linux") ]; }
            
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
            
            # Additional feature modules
            ./modules/proxychains.nix
            ./modules/dev.nix
            
            # ARM-specific configurations
            {
              nixpkgs.hostPlatform = "aarch64-linux";
              
              # Disable x86-specific services and hardware
              hardware.nvidia.enable = false;
              services.xserver.videoDrivers = [ "modesetting" ];
              
              # ARM-specific optimizations
              powerManagement = {
                enable = true;
                cpuFreqGovernor = "ondemand";
              };
              
              # VM-specific settings
              virtualisation = {
                # Define ARM-compatible virtualization settings
                # Most ARM machines use KVM for virtualization
                libvirtd.enable = true;
              };
            }
          ];
        };
        
        # Razer configuration
        razer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ (overlay-unstable "x86_64-linux") ]; }

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
          system = "x86_64-linux";
          modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ (overlay-unstable "x86_64-linux") ]; }

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
          system = "x86_64-linux";
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ (overlay-unstable "x86_64-linux") ]; }
            
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
            ./modules/scripts.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
          ];
        };

        # VM configuration
        VM = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ (overlay-unstable "x86_64-linux") ]; }
            
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
          system = "x86_64-linux";
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ (overlay-unstable "x86_64-linux") ]; }
            
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
