{ config, pkgs, lib, ... }:

with lib;

{

services.xserver.displayManager.startx.enable = true;
services.xserver.windowManager.i3.enable = true;
services.xserver.windowManager.i3.package = pkgs.i3-gaps;

environment.systemPackages = with pkgs; [
i3-gaps
i3lock-color
i3status
picom
feh
rofi
polybar
alacritty
flameshot
dunst
arandr
lxappearance
pavucontrol
xorg.xrandr
xorg.xmodmap
xclip
];

/*
services.picom = {
enable = true;
fade = true;
fadeDelta = 5;
fadeSteps = [0.028 0.03];
shadow = true;
shadowOffsets = [(-7) (-7)];
shadowOpacity = 0.7;
shadowRadius = 12;
activeOpacity = 0.95;
inactiveOpacity = 0.85;
backend = "glx";
vSync = true;
};
*/

}
