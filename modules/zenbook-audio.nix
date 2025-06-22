{ config, pkgs, lib, ... }:

with lib;

let
  # ZenBook S14 specific UCM configuration
  zenbook-ucm-conf = pkgs.runCommand "zenbook-ucm-conf" {} ''
    mkdir -p $out/share/alsa/ucm2/ASUSTeKCOMPUTERINC.-ASUSZenbookS14UX5406SA_UX5406SA-1.0-UX5406SA
    
    cat > $out/share/alsa/ucm2/ASUSTeKCOMPUTERINC.-ASUSZenbookS14UX5406SA_UX5406SA-1.0-UX5406SA/ASUSTeKCOMPUTERINC.-ASUSZenbookS14UX5406SA_UX5406SA-1.0-UX5406SA.conf <<'EOF'
Syntax 3

SectionUseCase."HiFi" {
	File "HiFi.conf"
	Comment "Play HiFi quality Music"
}
EOF

    cat > $out/share/alsa/ucm2/ASUSTeKCOMPUTERINC.-ASUSZenbookS14UX5406SA_UX5406SA-1.0-UX5406SA/HiFi.conf <<'EOF'
SectionVerb {
	EnableSequence [
		cset "name='AMP1 Speaker' on"
		cset "name='AMP2 Speaker' on" 
		cset "name='AMP3 Speaker' on"
		cset "name='AMP4 Speaker' on"
		cset "name='cs42l43 Speaker Digital' on"
		cset "name='Headphone' on"
		cset "name='Speaker' on"
		cset "name='cs42l43 Speaker L Input 1' 'DP5RX1'"
		cset "name='cs42l43 Speaker R Input 1' 'DP5RX2'"
		cset "name='cs42l43 Headphone Digital' 128,128"
	]
	
	DisableSequence [
		cset "name='cs42l43 Speaker Digital' off"
		cset "name='AMP1 Speaker' off"
		cset "name='AMP2 Speaker' off"
		cset "name='AMP3 Speaker' off" 
		cset "name='AMP4 Speaker' off"
	]
}

SectionDevice."Speaker" {
	Comment "Internal speakers"
	
	EnableSequence [
		cset "name='cs42l43 Speaker Digital' on"
		cset "name='AMP1 Speaker' on"
		cset "name='AMP2 Speaker' on"
		cset "name='AMP3 Speaker' on"
		cset "name='AMP4 Speaker' on"
		cset "name='cs42l43 Speaker L Input 1' 'DP5RX1'"
		cset "name='cs42l43 Speaker R Input 1' 'DP5RX2'"
		cset "name='cs42l43 Headphone Digital' 0,0"
	]
	
	DisableSequence [
		cset "name='cs42l43 Speaker Digital' off"
	]
	
	Value {
		PlaybackPCM "hw:sofsoundwire,2"
		PlaybackChannels 2
	}
}

SectionDevice."Headphones" {
	Comment "Headphones"
	
	EnableSequence [
		cset "name='cs42l43 Headphone L Input 1' 'DP5RX1'"
		cset "name='cs42l43 Headphone R Input 1' 'DP5RX2'"
		cset "name='cs42l43 Headphone Digital' 128,128"
		cset "name='Headphone' on"
		cset "name='cs42l43 Speaker Digital' off"
	]
	
	DisableSequence [
		cset "name='cs42l43 Headphone Digital' 0,0"
		cset "name='cs42l43 Headphone L Input 1' 'None'"
		cset "name='cs42l43 Headphone R Input 1' 'None'"
		cset "name='cs42l43 Speaker Digital' on"
	]
	
	Value {
		PlaybackPCM "hw:sofsoundwire,0"
		PlaybackChannels 2
		JackControl "Headphone Jack"
	}
}
EOF
  '';

  # Audio switching script
  zenbook-audio-switch = pkgs.writeShellScriptBin "zenbook-audio-switch" ''
    #!/bin/bash
    
    set -e
    
    CARD="sofsoundwire"
    
    usage() {
        echo "Usage: zenbook-audio-switch [speakers|headphones|status|toggle]"
        echo ""
        echo "Commands:"
        echo "  speakers     Switch to internal speakers"
        echo "  headphones   Switch to headphones"
        echo "  status       Show current audio device status"
        echo "  toggle       Toggle between speakers and headphones"
        echo ""
        exit 1
    }
    
    check_card() {
        if ! aplay -l | grep -q "$CARD"; then
            echo "Error: $CARD sound card not found"
            exit 1
        fi
    }
    
    enable_speakers() {
        echo "Switching to speakers..."
        
        # Enable speaker amplifiers
        amixer -c 0 sset 'AMP1 Speaker' on
        amixer -c 0 sset 'AMP2 Speaker' on
        amixer -c 0 sset 'AMP3 Speaker' on
        amixer -c 0 sset 'AMP4 Speaker' on
        amixer -c 0 sset 'cs42l43 Speaker Digital' on
        amixer -c 0 sset 'Speaker' on
        
        # Set speaker routing
        amixer -c 0 cset name='cs42l43 Speaker L Input 1' 'DP5RX1'
        amixer -c 0 cset name='cs42l43 Speaker R Input 1' 'DP5RX2'
        
        # Mute headphones
        amixer -c 0 sset 'cs42l43 Headphone Digital' 0,0 2>/dev/null || true
        
        # Set PipeWire default
        wpctl set-default $(wpctl status | grep -E "pro-output-2|Speaker" | head -1 | awk '{print $2}' | tr -d '.')
        
        echo "Switched to speakers"
    }
    
    enable_headphones() {
        echo "Switching to headphones..."
        
        # Set headphone routing and volume
        amixer -c 0 cset name='cs42l43 Headphone L Input 1' 'DP5RX1'
        amixer -c 0 cset name='cs42l43 Headphone R Input 1' 'DP5RX2'
        amixer -c 0 sset 'cs42l43 Headphone Digital' 50%
        amixer -c 0 sset 'Headphone' on
        
        # Optionally mute speakers to avoid feedback
        # amixer -c 0 sset 'cs42l43 Speaker Digital' off
        
        # Set PipeWire default
        wpctl set-default $(wpctl status | grep -E "pro-output-0|Jack" | head -1 | awk '{print $2}' | tr -d '.')
        
        echo "Switched to headphones"
    }
    
    show_status() {
        echo "=== ZenBook Audio Status ==="
        echo ""
        
        echo "PipeWire devices:"
        wpctl status | grep -A 20 "Audio" | grep -E "(Sinks:|Sources:|\*.*Controller)"
        echo ""
        
        echo "Speaker status:"
        for i in {1..4}; do
            amixer -c 0 sget "AMP$i Speaker" | grep -E "(Mono:|Front)"
        done
        amixer -c 0 sget 'cs42l43 Speaker Digital' | grep -E "(Front|Mono)"
        echo ""
        
        echo "Headphone status:"
        amixer -c 0 sget 'cs42l43 Headphone Digital' | grep -E "(Front|Mono)" || echo "Headphone control not found"
        echo ""
        
        echo "Current default sink:"
        wpctl status | grep -E "\*.*Controller" || echo "No default sink found"
    }
    
    toggle_audio() {
        current=$(wpctl status | grep -E "\*.*Controller.*pro-output" | head -1)
        if echo "$current" | grep -q "pro-output-2"; then
            enable_headphones
        else
            enable_speakers
        fi
    }
    
    # Main logic
    check_card
    
    case "''${1:-}" in
        speakers)
            enable_speakers
            ;;
        headphones)
            enable_headphones
            ;;
        status)
            show_status
            ;;
        toggle)
            toggle_audio
            ;;
        *)
            usage
            ;;
    esac
  '';

in {
  options.hardware.zenbook-audio = {
    enable = mkEnableOption "ZenBook S14 audio support";
    
    autoSwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic switching between speakers and headphones";
    };
    
    defaultVolume = mkOption {
      type = types.int;
      default = 50;
      description = "Default headphone volume percentage (0-100)";
    };
  };

  config = mkIf config.hardware.zenbook-audio.enable {
    
    # Force disable any existing audio configurations
    hardware.pulseaudio.enable = mkForce false;
    services.pipewire.pulse.enable = mkForce true;
    
    # Ensure latest kernel for Lunar Lake support  
    boot.kernelPackages = mkForce pkgs.linuxPackages_latest;
    
    # Required packages
    environment.systemPackages = with pkgs; [
      alsa-utils
      pavucontrol
      pipewire
      wireplumber
      zenbook-ucm-conf
      zenbook-audio-switch
    ];
    
    # Audio environment variables
    environment.variables = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    environment.sessionVariables = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    # Enable and configure PipeWire with ZenBook optimizations
    security.rtkit.enable = true;
    services.pipewire = {
      enable = mkForce true;
      alsa.enable = mkForce true;
      alsa.support32Bit = mkForce true;
      pulse.enable = mkForce true;
      jack.enable = mkDefault true;
      wireplumber.enable = mkForce true;
      
      # ZenBook-specific PipeWire configuration
      extraConfig.pipewire = {
        "10-zenbook-audio" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 2048;
          };
        };
      };
      
      # Force HiFi profile and proper device management
      wireplumber.extraConfig = {
        "50-zenbook-audio" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.name" = "~alsa_card.pci-.*sof_sdw";
                }
              ];
              actions = {
                update-props = {
                  "device.profile" = "HiFi";
                  "api.alsa.use-ucm" = true;
                  "api.alsa.auto-profile" = false;
                  "api.alsa.auto-port" = config.hardware.zenbook-audio.autoSwitch;
                };
              };
            }
          ];
        };
        
        "51-zenbook-device-names" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_output.pci-.*pro-output-2";
                }
              ];
              actions = {
                update-props = {
                  "node.description" = "ZenBook Built-in Speakers";
                  "device.icon-name" = "audio-speakers";
                  "device.intended-roles" = [ "Multimedia" ];
                };
              };
            }
            {
              matches = [
                {
                  "node.name" = "~alsa_output.pci-.*pro-output-0";
                }
              ];
              actions = {
                update-props = {
                  "node.description" = "ZenBook Headphones";
                  "device.icon-name" = "audio-headphones";
                  "device.intended-roles" = [ "Multimedia" ];
                };
              };
            }
          ];
        };
      };
    };
    
    # Set UCM environment for audio services
    systemd.user.services.pipewire.environment = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    systemd.user.services.wireplumber.environment = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    systemd.user.services.pipewire-pulse.environment = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    # Hardware firmware
    hardware.firmware = with pkgs; [
      sof-firmware
      linux-firmware  
      alsa-firmware
    ];
    
    # Enable all firmware loading
    hardware.enableAllFirmware = true;
    
    # Intel hardware optimizations
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    
    # Intel CPU optimizations
    hardware.cpu.intel.updateMicrocode = true;
    
    # Enable power management
    services.thermald.enable = true;
    services.power-profiles-daemon.enable = mkDefault false; # Avoid conflicts
    
    # Bluetooth audio support  
    hardware.bluetooth = {
      enable = mkDefault true;
      powerOnBoot = mkDefault true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    
    services.blueman.enable = mkDefault true;
    
    # udev rules for audio device permissions
    services.udev.extraRules = ''
      # ZenBook audio device permissions
      SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", GROUP="audio", MODE="0664"
      SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{class}=="0x040300", GROUP="audio", MODE="0664"
      
      # Automatic audio switching on headphone jack events
      ${optionalString config.hardware.zenbook-audio.autoSwitch ''
      ACTION=="change", SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", ENV{SOUND_FORM_FACTOR}=="headphones", RUN+="${zenbook-audio-switch}/bin/zenbook-audio-switch headphones"
      ACTION=="change", SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", ENV{SOUND_FORM_FACTOR}=="internal", RUN+="${zenbook-audio-switch}/bin/zenbook-audio-switch speakers"
      ''}
    '';
    
    # Audio initialization service
    systemd.user.services.zenbook-audio-init = {
      description = "ZenBook Audio Initialization";
      wantedBy = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${zenbook-audio-switch}/bin/zenbook-audio-switch speakers";
      };
    };
    
    # User shell aliases for convenience
    environment.shellAliases = {
      audio-speakers = "zenbook-audio-switch speakers";
      audio-headphones = "zenbook-audio-switch headphones"; 
      audio-status = "zenbook-audio-switch status";
      audio-toggle = "zenbook-audio-switch toggle";
    };
    
    # Documentation
    documentation.man.generateCaches = mkDefault true;
    
    # System info
    system.extraSystemBuilderCmds = ''
      echo "ZenBook S14 Audio Module: Enabled" > $out/zenbook-audio-info
      echo "UCM Config: ${zenbook-ucm-conf}" >> $out/zenbook-audio-info
      echo "Audio Switch: ${zenbook-audio-switch}" >> $out/zenbook-audio-info
    '';
  };
}
