{
description = "Griefhounds NixOS configuration";

inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

    # Pure VM guest: "just works" as a throwaway test/dev guest under VMware
    # or QEMU, no hosting duties, minimal footprint (no docker/forwarding,
    # no local DB/file-sync/remote-shell daemons - see modules/guest.nix).
    guest = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            ./modules/guest.nix

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
            ./modules/proxychains.nix
            ./modules/firefox.nix
        ];
    };

    # Host+guest: hosts VMs/containers via virt.nix (docker/libvirt, so
    # ip_forward stays on - hosting needs it), while also carrying the
    # self-gating guest-agent stack (modules/guest-agents.nix) so this same
    # config behaves correctly if it's ever run nested inside a hypervisor
    # too, with no manual toggling either way.
    host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
            { nixpkgs.config.allowUnfree = true; }
            { nixpkgs.overlays = [ overlay-unstable ]; }

            # Enable nix-index
            inputs.nix-index-database.nixosModules.nix-index

            # Base system configuration
            ./modules/configuration.nix
            ./modules/hwconf.nix
            ./modules/host.nix

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
};
};
}
