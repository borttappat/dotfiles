{ config, pkgs, lib, ... }:

let
  # Create a wrapper script with proper PATH
  monitorHotplugScript = pkgs.writeShellScript "monitor-hotplug-handler" ''
    export PATH="${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.util-linux}/bin:${pkgs.xorg.xrandr}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.i3}/bin:${pkgs.pywal}/bin:$PATH"
    exec ${pkgs.bash}/bin/bash /home/traum/dotfiles/scripts/bash/monitor-hotplug-handler-simple.sh
  '';
in
{
  # Udev rule for monitor hotplug detection
  services.udev.extraRules = ''
    # Detect monitor connect/disconnect events
    # Trigger on any DRM subsystem changes (catches HDMI, DP, USB-C, etc.)
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${monitorHotplugScript}"
  '';

  # Ensure the handler script is in the right location
  # This assumes your dotfiles are linked to ~/.config
  system.activationScripts.monitorHotplugSetup = ''
    mkdir -p /home/traum/.config/scripts
    if [ -f /home/traum/dotfiles/scripts/bash/monitor-hotplug-handler.sh ]; then
      ln -sf /home/traum/dotfiles/scripts/bash/monitor-hotplug-handler.sh /home/traum/.config/scripts/monitor-hotplug-handler.sh
      chmod +x /home/traum/.config/scripts/monitor-hotplug-handler.sh
    fi
  '';
}
