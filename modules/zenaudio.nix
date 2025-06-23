{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.zenbook-audio-enhanced;

  zenaudio-script = pkgs.writeShellScriptBin "zenaudio" ''
    #!/bin/bash
    
    set -e
    
    CARD="sofsoundwire"
    CARD_NUM=0
    
    usage() {
        echo "ZenBook Audio Switch - Manual device switching for ZenBook S14"
        echo ""
        echo "Usage: $0 [speakers|headphones|status|toggle|test|volume|mute|unmute]"
        echo ""
        echo "Device Commands:"
        echo "  speakers     Switch to internal speakers"
        echo "  headphones   Switch to headphones"
        echo "  toggle       Toggle between speakers and headphones"
        echo ""
        echo "Volume Commands:"
        echo "  volume [+|-|NUM]  Adjust volume (+ = up 5%, - = down 5%, NUM = set to %)"
        echo "  mute         Mute current device"
        echo "  unmute       Unmute current device"
        echo ""
        echo "Info Commands:"
        echo "  status       Show current audio device status"
        echo "  test         Test current audio output with tone"
        echo ""
        echo "Examples:"
        echo "  $0 headphones    # Switch to headphones"
        echo "  $0 volume +      # Increase volume by 5%"
        echo "  $0 volume 75     # Set volume to 75%"
        echo "  $0 mute          # Mute current device"
        echo "  $0 test          # Play test tone"
        echo ""
        exit 1
    }
    
    check_dependencies() {
        for cmd in amixer wpctl aplay; do
            if ! command -v "$cmd" >/dev/null 2>&1; then
                echo "Error: Required command '$cmd' not found"
                echo "Please install alsa-utils and pipewire tools"
                exit 1
            fi
        done
    }
    
    get_current_device() {
        CURRENT_DEFAULT=$(wpctl status | grep -E "\*.*Controller Pro")
        
        if echo "$CURRENT_DEFAULT" | grep -q "Pro 2"; then
            echo "speakers"
        elif echo "$CURRENT_DEFAULT" | grep -q "Pro \["; then
            echo "headphones"
        else
            echo "unknown"
        fi
    }
    
    get_current_volume() {
        local device_type=$(get_current_device)
        
        case "$device_type" in
            speakers)
                wpctl get-volume 47 2>/dev/null | awk '{print int($2*100)}' || echo "0"
                ;;
            headphones)
                amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%' | head -1
                ;;
            *)
                echo "0"
                ;;
        esac
    }
    
    set_volume() {
        local target_volume="$1"
        local device_type=$(get_current_device)
        
        if [ "$target_volume" -lt 0 ]; then
            target_volume=0
        elif [ "$target_volume" -gt 100 ]; then
            target_volume=100
        fi
        
        case "$device_type" in
            speakers)
                echo "Setting speaker volume to ''${target_volume}%..."
                wpctl set-volume 47 "''${target_volume}%" 2>/dev/null || echo "Warning: Could not set speaker volume"
                ;;
            headphones)
                echo "Setting headphone volume to ''${target_volume}%..."
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' "''${target_volume}%" >/dev/null || echo "Warning: Could not set headphone volume"
                ;;
            *)
                echo "Error: No audio device currently active"
                return 1
                ;;
        esac
        
        echo "Volume set to ''${target_volume}%"
    }
    
    adjust_volume() {
        local adjustment="$1"
        local current_volume=$(get_current_volume)
        local new_volume
        
        case "$adjustment" in
            +)
                new_volume=$((current_volume + 5))
                ;;
            -)
                new_volume=$((current_volume - 5))
                ;;
            [0-9]*)
                new_volume="$adjustment"
                ;;
            *)
                echo "Error: Invalid volume adjustment '$adjustment'"
                echo "Use: + (up 5%), - (down 5%), or a number (0-100)"
                return 1
                ;;
        esac
        
        set_volume "$new_volume"
    }
    
    mute_device() {
        local device_type=$(get_current_device)
        
        case "$device_type" in
            speakers)
                echo "Muting speakers..."
                wpctl set-mute 47 1 2>/dev/null || echo "Warning: Could not mute speakers"
                ;;
            headphones)
                echo "Muting headphones..."
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 0% >/dev/null || echo "Warning: Could not mute headphones"
                ;;
            *)
                echo "Error: No audio device currently active"
                return 1
                ;;
        esac
        
        echo "Device muted"
    }
    
    unmute_device() {
        local device_type=$(get_current_device)
        
        case "$device_type" in
            speakers)
                echo "Unmuting speakers..."
                wpctl set-mute 47 0 2>/dev/null || echo "Warning: Could not unmute speakers"
                ;;
            headphones)
                echo "Unmuting headphones..."
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 50% >/dev/null || echo "Warning: Could not unmute headphones"
                ;;
            *)
                echo "Error: No audio device currently active"
                return 1
                ;;
        esac
        
        echo "Device unmuted"
    }
    
    check_card() {
        if ! aplay -l | grep -q "$CARD"; then
            echo "Error: $CARD sound card not found"
            echo "This script is designed for ZenBook S14 with SOF audio"
            exit 1
        fi
    }
    
    enable_speakers() {
        echo "Switching to speakers..."
        
        echo "  - Enabling speaker amplifiers..."
        amixer -c $CARD_NUM sset 'AMP1 Speaker' on >/dev/null
        amixer -c $CARD_NUM sset 'AMP2 Speaker' on >/dev/null
        amixer -c $CARD_NUM sset 'AMP3 Speaker' on >/dev/null
        amixer -c $CARD_NUM sset 'AMP4 Speaker' on >/dev/null
        
        echo "  - Enabling speaker digital output..."
        amixer -c $CARD_NUM sset 'cs42l43 Speaker Digital' on >/dev/null
        amixer -c $CARD_NUM sset 'Speaker' on >/dev/null
        
        echo "  - Setting speaker routing..."
        amixer -c $CARD_NUM cset name='cs42l43 Speaker L Input 1' 'DP5RX1' >/dev/null
        amixer -c $CARD_NUM cset name='cs42l43 Speaker R Input 1' 'DP5RX2' >/dev/null
        
        echo "  - Muting headphones..."
        amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 0,0 >/dev/null 2>&1 || true
        
        echo "  - Setting PipeWire default..."
        SPEAKER_ID=$(wpctl status | grep -E "Controller Pro 2" | head -1 | awk '{print $2}' | tr -d '.')
        if [ -n "$SPEAKER_ID" ]; then
            wpctl set-default "$SPEAKER_ID" >/dev/null 2>&1 || echo "    Warning: Could not set PipeWire default"
            CURRENT_VOL=$(wpctl get-volume "$SPEAKER_ID" 2>/dev/null | awk '{print int($2*100)}' || echo "0")
            if [ "$CURRENT_VOL" -lt 30 ]; then
                wpctl set-volume "$SPEAKER_ID" 50% >/dev/null 2>&1
                echo "    Set default to device $SPEAKER_ID (speakers) at 50% volume"
            else
                echo "    Set default to device $SPEAKER_ID (speakers)"
            fi
        else
            wpctl set-default 47 >/dev/null 2>&1 && echo "    Set default to device 47 (speakers)" || echo "    Warning: Could not set PipeWire default"
        fi
        
        echo "✓ Switched to speakers (device hw:$CARD,2)"
    }
    
    enable_headphones() {
        echo "Switching to headphones..."
        
        echo "  - Setting headphone routing..."
        amixer -c $CARD_NUM cset name='cs42l43 Headphone L Input 1' 'DP5RX1' >/dev/null
        amixer -c $CARD_NUM cset name='cs42l43 Headphone R Input 1' 'DP5RX2' >/dev/null
        
        echo "  - Setting headphone volume..."
        amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 50% >/dev/null
        amixer -c $CARD_NUM sset 'Headphone' on >/dev/null
        
        echo "  - Setting PipeWire default..."
        HEADPHONE_ID=$(wpctl status | grep -E "Controller Pro \[" | head -1 | awk '{print $2}' | tr -d '.')
        if [ -n "$HEADPHONE_ID" ]; then
            wpctl set-default "$HEADPHONE_ID" >/dev/null 2>&1 || echo "    Warning: Could not set PipeWire default"
            echo "    Set default to device $HEADPHONE_ID (headphones)"
        else
            wpctl set-default 46 >/dev/null 2>&1 && echo "    Set default to device 46 (headphones)" || echo "    Warning: Could not set PipeWire default"
        fi
        
        echo "✓ Switched to headphones (device hw:$CARD,0)"
    }
    
    show_status() {
        echo "=== ZenBook Audio Status ==="
        echo ""
        
        echo "Hardware devices:"
        aplay -l | grep "$CARD" | sed 's/^/  /'
        echo ""
        
        echo "PipeWire sinks:"
        wpctl status | grep -A 10 "Sinks:" | grep -E "(Sinks:|\*.*Controller|[0-9]+\. )" | sed 's/^/  /'
        echo ""
        
        echo "Speaker amplifier status:"
        for i in {1..4}; do
            STATUS=$(amixer -c $CARD_NUM sget "AMP$i Speaker" | grep "Mono:" | grep -o "\[on\]\|\[off\]")
            echo "  AMP$i Speaker: $STATUS"
        done
        
        SPEAKER_DIGITAL=$(amixer -c $CARD_NUM sget 'cs42l43 Speaker Digital' | grep "Front Left:" | grep -o "\[on\]\|\[off\]")
        echo "  Speaker Digital: $SPEAKER_DIGITAL"
        echo ""
        
        echo "Headphone status:"
        HEADPHONE_VOL=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]')
        echo "  Headphone Volume: $HEADPHONE_VOL"
        echo ""
        
        echo "Current device & volume:"
        local device_type=$(get_current_device)
        local current_volume=$(get_current_volume)
        
        case "$device_type" in
            speakers)
                local mute_status=$(wpctl get-volume 47 2>/dev/null | grep -o "MUTED" || echo "")
                echo "  ✓ Speakers: ''${current_volume}% ''${mute_status}"
                ;;
            headphones)
                if [ "$current_volume" = "0" ]; then
                    echo "  ✓ Headphones: ''${current_volume}% MUTED"
                else
                    echo "  ✓ Headphones: ''${current_volume}%"
                fi
                ;;
            *)
                echo "  ? Unknown device"
                ;;
        esac
        echo ""
        
        echo "Current PipeWire default:"
        CURRENT_DEFAULT=$(wpctl status | grep -E "\*.*Controller" | head -1)
        if echo "$CURRENT_DEFAULT" | grep -q "Pro 2"; then
            echo "  ✓ Speakers (device $(echo "$CURRENT_DEFAULT" | awk '{print $2}' | tr -d '.'))"
        elif echo "$CURRENT_DEFAULT" | grep -q "Pro \["; then
            echo "  ✓ Headphones (device $(echo "$CURRENT_DEFAULT" | awk '{print $2}' | tr -d '.'))"
        else
            echo "$CURRENT_DEFAULT" | sed 's/^/  /' || echo "  No default found"
        fi
    }
    
    test_audio() {
        local device_type=$(get_current_device)
        local current_volume=$(get_current_volume)
        
        echo "Testing current audio output..."
        echo "Current device: $device_type at ''${current_volume}% volume"
        echo "You should hear a sine wave tone for 3 seconds"
        echo "Press Ctrl+C to stop early"
        echo ""
        
        CURRENT_DEFAULT=$(wpctl status | grep -E "\*.*Controller Pro")
        
        if echo "$CURRENT_DEFAULT" | grep -q "Pro 2"; then
            echo "Testing speakers (hw:$CARD,2)..."
            timeout 3 speaker-test -c2 -r48000 -D "hw:$CARD,2" -t sine -f 440 2>/dev/null || true
        elif echo "$CURRENT_DEFAULT" | grep -q "Pro \["; then
            echo "Testing headphones (hw:$CARD,0)..."
            timeout 3 speaker-test -c2 -r48000 -D "hw:$CARD,0" -t sine -f 440 2>/dev/null || true
        else
            echo "Could not determine current device, testing both:"
            echo "Testing speakers..."
            timeout 2 speaker-test -c2 -r48000 -D "hw:$CARD,2" -t sine -f 440 2>/dev/null || true
            echo "Testing headphones..."
            timeout 2 speaker-test -c2 -r48000 -D "hw:$CARD,0" -t sine -f 440 2>/dev/null || true
        fi
        
        echo "Test complete"
    }
    
    toggle_audio() {
        echo "Toggling audio output..."
        
        CURRENT_DEFAULT=$(wpctl status | grep -E "\*.*Controller Pro")
        
        if echo "$CURRENT_DEFAULT" | grep -q "Pro 2"; then
            echo "Currently on speakers, switching to headphones..."
            enable_headphones
        else
            echo "Currently on headphones (or unknown), switching to speakers..."
            enable_speakers
        fi
    }
    
    check_dependencies
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
        test)
            test_audio
            ;;
        volume)
            if [ -z "$2" ]; then
                current_volume=$(get_current_volume)
                device_type=$(get_current_device)
                echo "Current ''${device_type} volume: ''${current_volume}%"
            else
                adjust_volume "$2"
            fi
            ;;
        mute)
            mute_device
            ;;
        unmute)
            unmute_device
            ;;
        *)
            usage
            ;;
    esac
  '';

  zenbook-ucm-conf = pkgs.stdenv.mkDerivation {
    name = "zenbook-ucm-conf";
    src = pkgs.emptyDirectory;
    
    buildPhase = "true";
    
    installPhase = ''
      mkdir -p $out/share/alsa/ucm2/sof-soundwire
      
      cat > $out/share/alsa/ucm2/sof-soundwire/sof-soundwire.conf << 'EOF'
Syntax 4

SectionUseCase."HiFi" {
    File "HiFi.conf"
    Comment "Default"
}
EOF

      cat > $out/share/alsa/ucm2/sof-soundwire/HiFi.conf << 'EOF'
SectionVerb {
    EnableSequence [
        cset "name='cs42l43 Speaker Digital' on"
        cset "name='cs42l43 Headphone Digital' 0,0"
    ]
    
    DisableSequence [
    ]
    
    Value {
        TQ "HiFi"
    }
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
  };

in {
  options.hardware.zenbook-audio-enhanced = {
    enable = mkEnableOption "Enhanced ZenBook S14 audio support with full zenaudio functionality";
    
    autoSwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic switching between speakers and headphones";
    };
    
    defaultDevice = mkOption {
      type = types.enum [ "speakers" "headphones" ];
      default = "speakers";
      description = "Default audio output device on system startup";
    };
    
    defaultVolume = mkOption {
      type = types.int;
      default = 50;
      description = "Default volume percentage (0-100)";
    };
  };

  config = mkIf cfg.enable {
    
    hardware.pulseaudio.enable = mkForce false;
    services.pipewire.pulse.enable = mkForce true;
    
    boot.kernelPackages = mkForce pkgs.linuxPackages_latest;
    
    environment.systemPackages = with pkgs; [
      alsa-utils
      pavucontrol
      pipewire
      wireplumber
      zenbook-ucm-conf
      zenaudio-script
    ];
    
    environment.variables = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    environment.sessionVariables = {
      ALSA_CONFIG_UCM = "${zenbook-ucm-conf}/share/alsa/ucm";
      ALSA_CONFIG_UCM2 = "${zenbook-ucm-conf}/share/alsa/ucm2";
    };
    
    security.rtkit.enable = true;
    services.pipewire = {
      enable = mkForce true;
      alsa.enable = mkForce true;
      alsa.support32Bit = mkForce true;
      pulse.enable = mkForce true;
      jack.enable = mkDefault true;
      wireplumber.enable = mkForce true;
      
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
      
      wireplumber.extraConfig = {
        "50-zenbook-audio" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.name" = "~alsa_card.pci-.*_00_1f.3.*";
                }
              ];
              actions = {
                update-props = {
                  "device.profile" = "HiFi";
                  "audio.channels" = 2;
                  "audio.rate" = 48000;
                };
              };
            }
          ];
        };
      };
    };
    
    hardware.graphics = {
      enable = mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    
    hardware.cpu.intel.updateMicrocode = true;
    
    services.thermald.enable = true;
    services.power-profiles-daemon.enable = mkDefault false;
    
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
    
    services.udev.extraRules = ''
      SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", GROUP="audio", MODE="0664"
      SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{class}=="0x040300", GROUP="audio", MODE="0664"
      
      ${optionalString cfg.autoSwitch ''
      ACTION=="change", SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", ENV{SOUND_FORM_FACTOR}=="headphones", RUN+="${zenaudio-script}/bin/zenaudio headphones"
      ACTION=="change", SUBSYSTEM=="sound", ATTRS{id}=="sofsoundwire", ENV{SOUND_FORM_FACTOR}=="internal", RUN+="${zenaudio-script}/bin/zenaudio speakers"
      ''}
    '';
    
    systemd.user.services.zenbook-audio-init = {
      description = "ZenBook Audio Initialization";
      wantedBy = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${zenaudio-script}/bin/zenaudio ${cfg.defaultDevice}";
      };
    };
    
    environment.shellAliases = {
      audio-speakers = "zenaudio speakers";
      audio-headphones = "zenaudio headphones"; 
      audio-status = "zenaudio status";
      audio-toggle = "zenaudio toggle";
      audio-test = "zenaudio test";
      audio-mute = "zenaudio mute";
      audio-unmute = "zenaudio unmute";
      "audio-volume+" = "zenaudio volume +";
      "audio-volume-" = "zenaudio volume -";
    };
    
    documentation.man.generateCaches = mkDefault true;
    
    system.extraSystemBuilderCmds = ''
      echo "ZenBook S14 Enhanced Audio Module: Enabled" > $out/zenbook-audio-enhanced-info
      echo "Audio Script: ${zenaudio-script}" >> $out/zenbook-audio-enhanced-info
      echo "Default Device: ${cfg.defaultDevice}" >> $out/zenbook-audio-enhanced-info
      echo "Auto Switch: ${toString cfg.autoSwitch}" >> $out/zenbook-audio-enhanced-info
    '';
  };
}
