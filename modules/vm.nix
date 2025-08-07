# modules/vm.nix - Guest VM optimizations and enhancements
{ config, pkgs, lib, ... }:

{
  # QEMU Guest Agent for better host-guest integration
  services.qemuGuest.enable = true;

  # SPICE vdagent for clipboard sharing and display management
  services.spice-vdagentd.enable = true;

  # VM-specific packages
  environment.systemPackages = with pkgs; [
    # SPICE tools for clipboard and display
    spice-vdagent
    spice-gtk
    
    # X11 tools for resolution management
    xorg.xrandr
    xorg.xdpyinfo
    
    # Clipboard utilities
    xclip
    xsel
  ];

  # Virtio kernel modules for VM hardware
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi" 
    "virtio_blk"
    "virtio_net"
    "virtio_balloon"
    "virtio_console"
    "qxl"
  ];

  # Enable additional virtio modules
  boot.kernelModules = [ 
    "virtio_balloon" 
    "virtio_console"
    "virtio_gpu"
  ];

  # VM performance optimizations
  boot.kernel.sysctl = {
    # Reduce swappiness for better VM performance on limited RAM
    "vm.swappiness" = 10;
    # Increase file handles for VM workloads  
    "fs.file-max" = 65536;
  };

  # X11 display configuration optimized for VMs
  services.xserver = {
    # VM-optimized display drivers
    videoDrivers = [ "qxl" "virtio" "vesa" ];
    
    # Automatic resolution configuration
    displayManager.sessionCommands = '\'''\'
      # Add custom resolutions
      ${pkgs.xorg.xrandr}/bin/xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
      ${pkgs.xorg.xrandr}/bin/xrandr --newmode "1440x900_59.89" 106.50 1440 1528 1672 1904 900 903 909 934 -hsync +vsync
      
      # Add modes to available outputs
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 "1920x1080_60.00" 2>/dev/null || true
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode qxl-0 "1920x1080_60.00" 2>/dev/null || true
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 "1440x900_59.89" 2>/dev/null || true
      ${pkgs.xorg.xrandr}/bin/xrandr --addmode qxl-0 "1440x900_59.89" 2>/dev/null || true
      
      # Set optimal resolution (try highest first, fallback to lower)
      ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output qxl-0 --mode 1920x1080 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 1440x900 2>/dev/null || \
      ${pkgs.xorg.xrandr}/bin/xrandr --output qxl-0 --mode 1440x900 2>/dev/null || true
    '\'';
  };

  # Enhanced SPICE vdagent service for clipboard sharing
  systemd.user.services.spice-vdagent = {
    description = "SPICE vdagent for clipboard sharing and display management";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
      Restart = "always";
      RestartSec = 3;
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=%h/.Xauthority"
      ];
    };
  };

  # Auto-resize display when VM window changes
  systemd.user.services.vm-display-resize = {
    description = "Auto-resize VM display when window size changes";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeScript "vm-display-resize" '\'''\'
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        
        while true; do
          # Only run if X server is active
          if ${pkgs.procps}/bin/pgrep -x "Xorg\|X" > /dev/null 2>&1; then
            # Check if we'\''re in a VM
            if ${pkgs.systemd}/bin/systemd-detect-virt -q 2>/dev/null; then
              # Get current resolution and available resolutions
              CURRENT_RES=$(${pkgs.xorg.xrandr}/bin/xrandr | grep '\''*'\'' | awk '\''{print $1}'\'' | head -1)
              OPTIMAL_RES=$(${pkgs.xorg.xrandr}/bin/xrandr | grep -E '\''^[[:space:]]*[0-9]+x[0-9]+'\'' | awk '\''{print $1}'\'' | sort -t'\''x'\'' -k1,1nr -k2,2nr | head -1)
              
              # If optimal resolution is different and not the default 1024x768, switch to it
              if [ -n "$OPTIMAL_RES" ] && [ "$OPTIMAL_RES" != "$CURRENT_RES" ] && [ "$OPTIMAL_RES" != "1024x768" ]; then
                ${pkgs.xorg.xrandr}/bin/xrandr -s "$OPTIMAL_RES" 2>/dev/null || true
              fi
            fi
          fi
          sleep 5
        done
      '\'';
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=%h/.Xauthority"
      ];
    };
  };

  # Disable services that are unnecessary or problematic in VMs
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-networkd-wait-online.enable = false;
  
  # Disable hardware-specific services for VMs
  services.udisks2.enable = lib.mkDefault false;
  services.power-profiles-daemon.enable = lib.mkDefault false;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Optimize font rendering for VM displays
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel.rgba = "rgb";
  };

  # VM-specific security and performance settings
  security.polkit.enable = true;
  
  # Faster shutdown for VMs
  systemd.extraConfig = '\'''\'
    DefaultTimeoutStopSec=10s
    DefaultTimeoutStartSec=10s
  '\'';

  # Optimize for VM environment
  environment.variables = {
    # Hint to applications that we'\''re in a VM
    VIRTUALIZATION = "1";
  };

  # VM-optimized swapping
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25;
  };
}
