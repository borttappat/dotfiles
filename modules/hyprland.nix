{ config, pkgs, lib, ... }:

with lib;

{
options.hyprland.enable = mkEnableOption "Hyprland wayland compositor";

config = mkIf config.hyprland.enable {
services.xserver.enable = true;
services.xserver.displayManager.gdm.enable = true;
services.xserver.displayManager.gdm.wayland = true;

programs.hyprland = {
enable = true;
xwayland.enable = true;
};

environment.sessionVariables = {
WLR_NO_HARDWARE_CURSORS = "1";
NIXOS_OZONE_WL = "1";
};

environment.systemPackages = with pkgs; [
hyprland
hyprpaper
hypridle
hyprlock
waybar
wofi
dunst
grim
slurp
wl-clipboard
wf-recorder
swaynotificationcenter
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
pamixer
brightnessctl
];

xdg.portal = {
enable = true;
wlr.enable = true;
extraPortals = with pkgs; [
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
];
};

security.pam.services.hyprlock = {};

fonts.packages = with pkgs; [
cozette
hack-font
font-awesome
powerline-fonts
nerdfonts
];
};
}
