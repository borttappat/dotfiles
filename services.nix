{ config, pkgs, ... }:

{
# Asusd
#    services.asusd.enable = true;

# Undervolt
   # services.undervolt = {
   #     enable = false;
   #     coreOffset = -80;
   # };
# Mullvad-vpn
    services.mullvad-vpn.enable = true;

# Behaviour settings for closing lid on external power
    services.logind.lidSwitchExternalPower = "ignore";

# Fish-shell
    programs.fish.enable=true;
    users.defaultUserShell = pkgs.fish;

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

# Enabling OpenRGB
    services.hardware.openrgb.enable = true;

# Enable the X11 windowing system
    services.xserver.enable = true;

# Enable the GNOME Desktop Environment
    #services.xserver.displayManager.gdm.enable = true;
    #services.xserver.desktopManager.gnome.enable = true;

# Window- and Display-manager settings
    services.xserver.displayManager.startx.enable = true;
    services.xserver.windowManager.i3.enable = true;

# Enable touchpad support
    services.xserver.libinput.enable = true;

# Configure keymap in X11
    services.xserver = {
        layout = "se";
        xkbVariant = "";
    };
}
