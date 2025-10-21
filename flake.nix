{
description = "Griefhounds NixOS configuration";

inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
let
    # Detect architecture dynamically
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
  
    # Helper function to create an attribute set for each supported system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  
    # Function to make pkgs available for a specific system
    pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
    };

    # Overlay to make unstable packages available
    overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
        };
  };

in {
     devShells.x86_64-linux = (import ./modules/bloodhound.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    }).devShells;

    nixosConfigurations = {
    
    # Configurations with system specific to architecture
    razer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Enable nix-index
            inputs.nix-index-database.nixosModules.nix-index

            # Base system configuration
            ./modules/configuration.nix
            
            # Device specific configurations
            ./modules/razer.nix
            ./modules/hwconf.nix
            
            # Core functionality modules
            ./modules/i3.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/virt.nix
            ./modules/scripts.nix
            ./modules/audio.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
        ];
    };

    # Zephyrus configuration  
    zephyrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Enable nix-index
            inputs.nix-index-database.nixosModules.nix-index
            
            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            
            # Device specific configurations
            ./modules/zephyrus.nix
            #./modules/zephyrusconf.nix
            
            # Core functionality modules
            ./modules/i3.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            #./modules/hosts.nix
            ./modules/virt.nix
            #./modules/scripts.nix
            ./modules/audio.nix

            
            # Additional feature modules
            #./modules/pentesting.nix
            #./modules/proxychains.nix
            #./modules/dev.nix
            #./modules/steam.nix
        ];
    }; 

    #Zenbook configuration  
    zenbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            
            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Enable nix-index
            inputs.nix-index-database.nixosModules.nix-index
            
            /*
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.traum = import ./modules/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            */


            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            
            # Device specific configurations
            ./modules/zenbook.nix
            ./modules/i3.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            #./modules/hosts.nix
            ./modules/virt.nix
            ./modules/scripts.nix
            
            # Additional feature modules
            #./modules/pentesting.nix
            #./modules/proxychains.nix
            #./modules/dev.nix
            ./modules/steam.nix
            #./modules/gaming.nix
            ./modules/audio.nix
            ./modules/firefox.nix
        ];
    };
        
    #XMG Configuration
    xmg = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
            ./modules/hwconf.nix
            
            # Core functionality modules
            ./modules/i3.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
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
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            
            # Device specific configurations
            ./modules/asus.nix
            ./modules/asusconf.nix
            
            # Core functionality modules
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/virt.nix
            ./modules/scripts.nix
            
            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/proxychains.nix
            ./modules/dev.nix
            ./modules/steam.nix
        ];
    };

    # x86_64 VM configuration
    VM = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            ./modules/vm-hwconf.nix
            ./modules/vm-guest.nix
            
            # Core functionality modules
            ./modules/i3.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/audio.nix

            # Additional feature modules
            ./modules/pentesting.nix
            ./modules/havoc-deps.nix
            ./modules/proxychains.nix
            ./modules/firefox.nix
        ];
    };

    # ARM-specific VM configuration
    armVM = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
            # Make unfree packages allowable
            { nixpkgs.config.allowUnfree = true; }

            # Add overlay to the system
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # ARM VM specific configuration
            ./modules/arm-vm.nix
            ./modules/hwconf.nix 
            
            # Core functionality modules (non-hardware specific)
            ./modules/i3.nix
            ./modules/pentesting.nix
            ./modules/colors.nix
            ./modules/hosts.nix
            ./modules/audio.nix

        ];
    };       

    # Default configuration
    default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }
            
            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            
            # Core functionality modules
            ./modules/i3.nix
            ./modules/packages.nix
            ./modules/services.nix
            ./modules/users.nix
            ./modules/colors.nix
            #./modules/virt.nix
            ./modules/scripts.nix
            ./modules/audio.nix
        ];
    };
};
};
}
