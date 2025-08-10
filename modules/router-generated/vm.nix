# Router VM NixOS Configuration
# This will run inside the VM with the passed-through WiFi card

{ config, pkgs, ... }:

{
  # Basic system configuration
  system.stateVersion = "24.05";
  
  # Enable WiFi and networking
  networking = {
    hostName = "router-vm";
    wireless.enable = true;
    wireless.networks = {
      # Configure your WiFi network here
      # "YourNetworkName" = {
      #   psk = "your-password";
      # };
    };
    
    # Enable IP forwarding for routing
    enableIPv6 = false;  # Simplify for now
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 53 ];
      allowedUDPPorts = [ 53 67 68 ];
    };
  };

  # DHCP server for guest VMs

  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "8.8.8.8" "1.1.1.1" ];
      interface = [ "enp2s0" ];
    };
  };

  # NAT configuration
  networking.nat = {
    enable = true;
    internalInterfaces = [ "enp2s0" ];
    externalInterface = "wlan0";  # WiFi interface from passthrough
  };

  # SSH for management
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Essential packages
  environment.systemPackages = with pkgs; [
    wirelesstools
    iw
    tcpdump
    netcat
    iptables
  ];

  # Auto-login for console access
  services.getty.autologinUser = "router";
  
  # Create router user
  users.users.router = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Add your SSH keys here
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
  };
}
