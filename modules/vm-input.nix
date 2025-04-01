# modules/vm-input.nix
{ config, lib, pkgs, ... }:

{
  # Enhanced input handling for VM
  environment.systemPackages = with pkgs; [
    xorg.xf86inputevdev
    xorg.xf86inputlibinput
    spice-vdagent
    virtio-win
  ];

  # Force libinput for better VM input handling
  services.xserver.modules = [ pkgs.xorg.xf86inputlibinput ];
  
  # Ensure evdev is available
  services.xserver.config = ''
    Section "InputClass"
        Identifier "evdev keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
        Option "XkbLayout" "se"
    EndSection
    
    Section "InputClass"
        Identifier "libinput keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "XkbLayout" "se"
    EndSection
  '';
  
  # Add compatibility symlinks for input devices
  boot.initrd.postDeviceCommands = ''
    if [ ! -e /dev/input ]; then
      mkdir -p /dev/input
    fi
  '';
  
  # Try both console keymap settings that might work
  console = {
    keyMap = "sv-latin1";
    packages = [ pkgs.kbd ];
  };
}
