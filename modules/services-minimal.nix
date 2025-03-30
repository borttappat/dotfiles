{ config, pkgs, ... }:

{
  # NetworkManager configuration - minimal setup
  systemd.services.NetworkManager-wait-online = {
    enable = false;
  };

  networking = {
    networkmanager = {
      enable = true;  
    };
  };
    
  # avoid issues with #/bin/bash scripts and alike
  services.envfs.enable = true;

  # Sound-settings (minimal)
  services.pipewire.pulse.enable = true;

  # udisksctl
  services.udisks2.enable = true;

  # Window-manager (minimal setup)
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Disable resource-intensive or hardware-specific services
  services.auto-cpufreq.enable = false;
  services.hardware.openrgb.enable = false;
  services.mullvad-vpn.enable = false;
  services.resolved.enable = false;
  services.tailscale.enable = false;
  hardware.bluetooth.enable = false;
  hardware.i2c.enable = false;
}
