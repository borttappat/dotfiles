#                        __                           __
#.-----.-----.----.--.--|__.----.-----.-----.  .-----|__.--.--.
#|__ --|  -__|   _|  |  |  |  __|  -__|__ --|__|     |  |_   _|
#|_____|_____|__|  \___/|__|____|_____|_____|__|__|__|__|__.__|

{ config, pkgs, ... }:

{

# NetworkManager configuration
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

# Sound-settings
services.pipewire.pulse.enable = true;

# ollama, LLM
services.ollama.enable = true;

# udisksctl
services.udisks2.enable = true; #added with udisks in packages.nix

# Docker-support
virtualisation.docker.enable = true; #added with docker pkg in packages.nix

# Mullvad-vpn
services.mullvad-vpn.enable = true;
services.resolved.enable = true;

# Behaviour settings for closing lid on external power
services.logind.lidSwitchExternalPower = "ignore";

# Rsync
# services.rsyncd.enable = true;

# Enable touchpad support
services.libinput.enable = true;

# Virtualisation
virtualisation.libvirtd.enable = true;
programs.dconf.enable = true;
environment.systemPackages = with pkgs; [ virt-manager ];

# MySQL
/*    
services.mysql = {
    enable = true;
    package = pkgs.mariadb;
};
*/

# Window-manager
services.xserver.windowManager.i3.package = pkgs.i3-gaps; 	
#services.xserver.windowManager.i3.package = pkgs.i3-rounded;

# Enabling auto-cpufreq
services.auto-cpufreq.enable = true;

# Intel-undervolt
#services.undervolt.enable = true;

# Enable the OpenSSH daemon.
services.openssh.enable = true;

# Enabling tailscale VPN
services.tailscale.enable = true;

# Enable i2c-bus
hardware.i2c.enable = true;




# Undervolt
   # services.undervolt = {
   #     enable = false;
   #     coreOffset = -80;
   # };


}
