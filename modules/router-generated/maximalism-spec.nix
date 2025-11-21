# Maximalism Specialisation Template
# Combines Router VM + Pentest VM (pentest-vm-auto) autostart
# Generated for VM: pentest-vm-auto
# VM Image: /home/traum/splix/pentest-vm/result/nixos.qcow2
# Workspace: 2

{ config, lib, pkgs, ... }:
{
  specialisation.maximalism.configuration = {
  system.nixos.label = lib.mkForce "maximalism-setup";
  
  # Enable router VM blacklisting for maximalism mode
  boot.blacklistedKernelModules = [ "iwlwifi" ];
  
  # Set default route through router VM
  networking.defaultGateway = {
    address = "192.168.100.253";
    interface = "virbr1";
  };
  
  # Router VM Auto-start service (inherited from router mode)
  systemd.services.router-vm-autostart = {
    description = "Auto-start existing router VM in maximalism mode";
    after = [ 
      "libvirtd.service" 
      "network.target"
      "network-online.target"
    ];
    wants = [ "libvirtd.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/traum/splix/generated/scripts/autostart-router-vm.sh";
      RemainAfterExit = true;
      User = "root";
      TimeoutStartSec = "120s";
      Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin";
    };
  };
  
  # Pentest VM Auto-start service
  systemd.services.pentest-vm-auto-autostart = {
    description = "Auto-start pentest-vm-auto pentest VM";
    after = [ 
      "router-vm-autostart.service"
      "libvirtd.service" 
      "network.target"
      "network-online.target"
    ];
    wants = [ "router-vm-autostart.service" "libvirtd.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      TimeoutStartSec = "120s";
      Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin";
    };
    
    script = ''
      log() { echo "[$(date +%H:%M:%S)] Pentest VM Autostart: $*"; }
      
      # Use full paths since systemd has limited PATH
      VIRSH="/run/current-system/sw/bin/virsh"
      SYSTEMCTL="/run/current-system/sw/bin/systemctl"
      
      log "Starting pentest-vm-auto autostart process..."
      
      # Wait for router VM to be fully started first
      log "Waiting for router VM to be ready..."
      sleep 10
      
      # Check if libvirtd is running
      if ! $SYSTEMCTL is-active --quiet libvirtd; then
        log "Starting libvirtd service..."
        $SYSTEMCTL start libvirtd
        sleep 3
        log "Libvirtd started"
      fi
      
      # Wait for libvirtd to be fully ready
      sleep 2
      
      # Check if VM exists
      if ! $VIRSH --connect qemu:///system list --all | grep -q "pentest-vm-auto"; then
        log "ERROR: Pentest VM 'pentest-vm-auto' not found"
        log "Please ensure the VM is properly created"
        exit 1
      fi
      
      # Check current VM state
      vm_state=$($VIRSH --connect qemu:///system list --all | grep "pentest-vm-auto" | awk '{print $3}' || echo "unknown")
      log "Pentest VM current state: $vm_state"
      
      case "$vm_state" in
        "running")
          log "pentest-vm-auto is already running - nothing to do"
          ;;
        "shut"|"shutoff")
          log "Starting pentest-vm-auto..."
          if $VIRSH --connect qemu:///system start "pentest-vm-auto"; then
            log "pentest-vm-auto started successfully"
            sleep 3
          else
            log "ERROR: Failed to start pentest-vm-auto"
            exit 1
          fi
          ;;
        *)
          log "pentest-vm-auto in unexpected state: $vm_state"
          log "Attempting to start anyway..."
          if $VIRSH --connect qemu:///system start "pentest-vm-auto"; then
            log "pentest-vm-auto started despite unexpected state"
            sleep 3
          else
            log "ERROR: Failed to start pentest-vm-auto"
            exit 1
          fi
          ;;
      esac
      
      # Final verification
      if $VIRSH --connect qemu:///system list | grep -q "pentest-vm-auto.*running"; then
        log "pentest-vm-auto is running and ready"
        log "Assigned to workspace 2"
        log "Router VM also running for network isolation"
      else
        log "pentest-vm-auto startup verification failed"
        exit 1
      fi
      
      log "pentest-vm-auto autostart completed successfully"
    '';
  };

  # Workspace assignment service for pentest VM
  systemd.services.pentest-vm-auto-workspace-assignment = {
    description = "Assign pentest-vm-auto to workspace 2 and fullscreen";
    after = [ 
      "pentest-vm-auto-autostart.service"
      "graphical-session.target"
    ];
    wants = [ "pentest-vm-auto-autostart.service" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "traum";
      Environment = [
        "DISPLAY=:0"
        "WAYLAND_DISPLAY=wayland-0"
        "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin"
      ];
    };
    
    script = ''
      log() { echo "[$(date +%H:%M:%S)] Workspace Assignment: $*"; }
      
      # Wait for VM to be fully started and window manager to be ready
      sleep 15
      
      log "Setting up workspace 2 for pentest-vm-auto..."
      
      # Try i3 workspace switching
      if command -v i3-msg >/dev/null 2>&1; then
        log "Detected i3, configuring workspace..."
        i3-msg "workspace 2"
        sleep 2
        # Focus any virt-manager or VM window and fullscreen it
        i3-msg "[class=\"Virt-manager\"] focus, fullscreen enable" || true
        i3-msg "[class=\"qemu\"] focus, fullscreen enable" || true
        log "Workspace 2 configured for pentest-vm-auto"
      else
        log "Could not configure workspace automatically (i3 not detected)"
        log "Manually switch to workspace 2 and open virt-manager"
      fi
    '';
  };

  # Add additional tools for maximalism mode
  environment.systemPackages = with pkgs; lib.mkAfter [
    virt-manager
    
    # Combined status command for maximalism mode
    (writeShellScriptBin "maximalism-status" ''
      echo "MAXIMALISM MODE Status"
      echo "======================"
      echo ""
      
      echo "Router VM Status:"
      sudo virsh list --all | grep router || echo "Router VM not found"
      echo ""
      
      echo "Pentest VM (pentest-vm-auto) Status:"
      sudo virsh list --all | grep "pentest-vm-auto" || echo "pentest-vm-auto not found"
      echo ""
      
      echo "Network Status:"
      echo "  Router Bridge: $(ip link show virbr1 2>/dev/null | grep -o 'state [A-Z]*' || echo 'DOWN')"
      echo "  Default Route: $(ip route | grep default | awk '{print $5}' | head -1 || echo 'unknown')"
      echo ""
      
      echo "Workspace Info:"
      echo "  Target Workspace: 2"
      echo "  VM Image: /home/traum/splix/pentest-vm/result/nixos.qcow2"
      echo ""
      
      echo "Quick Actions:"
      echo "  Start pentest-vm-auto:    sudo virsh start pentest-vm-auto"
      echo "  Stop pentest-vm-auto:     sudo virsh shutdown pentest-vm-auto"
      echo "  Router Console:       sudo virsh console router-vm-passthrough"
      echo "  pentest-vm-auto Console:  sudo virsh console pentest-vm-auto"
      echo "  VM Manager:           virt-manager"
    '')
  ];
  
  # Optional: Auto-switch to workspace on login (user service)
  systemd.user.services.maximalism-login-workspace = {
    description = "Switch to workspace 2 on login for maximalism mode";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Wait for desktop environment to fully load
      sleep 20
      
      # Try to switch to workspace 2 with i3
      if command -v i3-msg >/dev/null 2>&1; then
        i3-msg "workspace 2" || true
      fi
    '';
  };
  };
}
