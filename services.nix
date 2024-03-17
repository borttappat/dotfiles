#                          _                        _
#    ________  ______   __(_)_______  _____  ____  (_)  __
#   / ___/ _ \/ ___/ | / / / ___/ _ \/ ___/ / __ \/ / |/_/
#  (__  )  __/ /   | |/ / / /__/  __(__  ) / / / / />  <
# /____/\___/_/    |___/_/\___/\___/____(_)_/ /_/_/_/|_|

{ config, pkgs, ... }:

{

# udisksctl
    services.udisks2.enable = true; #added with udisks in packages.nix

    # Settings for making mounting/unmounting easier
    #services.gvfs.enable = true; #added for easier mounting/unmounting of usb disks
    #services.devmon.enable = true; #added for easier mounting/unmounting of usb disks 

# Docker-support
    virtualisation.docker.enable = true; #added with docker pkg in packages.nix


# Mullvad-vpn
    services.mullvad-vpn.enable = true;
    services.resolved.enable = true;



# Behaviour settings for closing lid on external power
    services.logind.lidSwitchExternalPower = "ignore";

# Rsync
    services.rsyncd.enable = true;

# Enable touchpad support
    services.xserver.libinput.enable = true;


# Fish-shell
    programs.fish.enable=true;
    users.defaultUserShell = pkgs.fish;
    environment.shells = with pkgs; [ fish ];


# Virtualisation
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager ];
    
    services.xrdp.enable = true; #added along with xrdp package in packages.nix


# OpenGL
    #hardware.opengl.extraPackages = with pkgs; [ intel-media-driver intel-ocl vaapiIntel ];
    #hardware.opengl.enable = true;
    # Video acceleration
    # 9a49 is sourced from the output of command: $ nix-shell -p pciutils --run "lspci -nn     | grep VGA"
    #boot.kernelParams = [ "i915.force_probe=9a49" ];


# MySQL
    services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        };


# i3-lock
    programs.i3lock.enable=true;


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


# Enabling OpenRGB *moved to razer.nix*
    #services.hardware.openrgb.enable = true;


# Enable i2c-bus
    hardware.i2c.enable = true;


# Enable Automatic Upgrades
    system.autoUpgrade.enable = true;


# Undervolt
   # services.undervolt = {
   #     enable = false;
   #     coreOffset = -80;
   # };



# Asusd
#    services.asusd.enable = true;

# Enable the GNOME Desktop Environment
    #services.xserver.displayManager.gdm.enable = true;
    #services.xserver.desktopManager.gnome.enable = true;


# Do not allow for automatic reboots
    # system.autoUpgrade.allowReboot = true;


# Enable Flatpak
    #xdg.portal.enable = true; # only needed if you are not doing Gnome
    #services.flatpak.enable = true;
    # Run this command to add flathub
    # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


# Setup NUR
    #nixpkgs.config.packageOverrides = pkgs: {
    #nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        #inherit pkgs;
        #};
    #};
}
