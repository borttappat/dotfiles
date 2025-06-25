#!/bin/bash

set -e

CARD="sofsoundwire"
CARD_NUM=0

usage() {
    echo "ZenBook Audio Switch - Dynamic device switching for ZenBook S14"
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
    exit 1
}

check_dependencies() {
    for cmd in amixer wpctl aplay pactl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: Required command '$cmd' not found"
            exit 1
        fi
    done
}

find_sof_card() {
    pactl list cards short | grep -i "sof\|soundwire" | head -1 | awk '{print $2}' || {
        echo "Error: SOF soundwire card not found"
        exit 1
    }
}

ensure_card_profile() {
    local card_name=$(find_sof_card)
    pactl set-card-profile "$card_name" pro-audio >/dev/null 2>&1
    sleep 2
}

find_device_ids() {
    local headphone_device=""
    local speaker_device=""
    
    local headphone_device=$(wpctl status | grep -E "pro-output-0|Jack Out" | head -1 | awk '{print $1}' | tr -d '*.')
    local speaker_device=$(wpctl status | grep -E "pro-output-2|Speaker" | head -1 | awk '{print $1}' | tr -d '*.')
    
    if [ -z "$headphone_device" ] || [ -z "$speaker_device" ]; then
        headphone_device=$(pactl list sinks short | grep "pro-output-0" | awk '{print $1}')
        speaker_device=$(pactl list sinks short | grep "pro-output-2" | awk '{print $1}')
    fi
    
    if [ -z "$headphone_device" ] || [ -z "$speaker_device" ]; then
        echo "Error: Could not find headphone or speaker devices"
        echo "Available devices:"
        wpctl status | grep -A 20 "Sinks:"
        exit 1
    fi
    
    echo "$headphone_device $speaker_device"
}

check_card() {
    if ! aplay -l | grep -q "$CARD"; then
        echo "Error: $CARD sound card not found"
        exit 1
    fi
    
    ensure_card_profile
    
    local devices=$(find_device_ids)
    HEADPHONE_DEVICE=$(echo $devices | awk '{print $1}')
    SPEAKER_DEVICE=$(echo $devices | awk '{print $2}')
    
    if [ -z "$HEADPHONE_DEVICE" ] || [ -z "$SPEAKER_DEVICE" ]; then
        echo "Error: Failed to discover device IDs"
        exit 1
    fi
}

get_current_device() {
    HEADPHONE_VOL=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' 2>/dev/null | grep "Front Left:" | awk '{print $4}' | tr -d '[]%' | head -1 || echo "0")
    if [ "$HEADPHONE_VOL" -gt 0 ] 2>/dev/null; then
        echo "headphones"
    else
        echo "speakers"
    fi
}

enable_speakers() {
    echo "Switching to speakers..."
    
    amixer -c $CARD_NUM sset 'AMP1 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP2 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP3 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP4 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'cs42l43 Speaker Digital' on >/dev/null
    amixer -c $CARD_NUM sset 'Speaker' on >/dev/null
    
    amixer -c $CARD_NUM cset name='cs42l43 Speaker L Input 1' 'DP5RX1' >/dev/null
    amixer -c $CARD_NUM cset name='cs42l43 Speaker R Input 1' 'DP5RX2' >/dev/null
    
    amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 0,0 >/dev/null 2>&1 || true
    
    wpctl set-default $SPEAKER_DEVICE >/dev/null 2>&1
    wpctl set-volume $SPEAKER_DEVICE 50% >/dev/null 2>&1
    
    echo "✓ Switched to speakers (device $SPEAKER_DEVICE)"
}

enable_headphones() {
    echo "Switching to headphones..."
    
    amixer -c $CARD_NUM cset name='cs42l43 Headphone L Input 1' 'DP5RX1' >/dev/null
    amixer -c $CARD_NUM cset name='cs42l43 Headphone R Input 1' 'DP5RX2' >/dev/null
    amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 50% >/dev/null
    amixer -c $CARD_NUM sset 'Headphone' on >/dev/null
    
    wpctl set-default $HEADPHONE_DEVICE >/dev/null 2>&1
    
    echo "✓ Switched to headphones (device $HEADPHONE_DEVICE)"
}

show_status() {
    echo "=== ZenBook Audio Status ==="
    echo ""
    
    device_type=$(get_current_device)
    echo "Current device: $device_type"
    echo "Discovered devices: Headphones=$HEADPHONE_DEVICE, Speakers=$SPEAKER_DEVICE"
    echo "SOF Card: $(find_sof_card)"
    
    echo ""
    echo "PipeWire status:"
    wpctl status | grep -A 20 "Sinks:" | sed 's/^/  /'
    
    echo ""
    echo "Hardware status:"
    echo "  Speakers: $(amixer -c $CARD_NUM sget 'cs42l43 Speaker Digital' | grep "Front Left:" | grep -o "\[on\]\|\[off\]")"
    echo "  Headphones: $(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]')"
}

test_audio() {
    device_type=$(get_current_device)
    echo "Testing $device_type..."
    echo "You should hear a 3-second tone"
    
    case "$device_type" in
        speakers)
            timeout 3 speaker-test -c2 -r48000 -D "hw:$CARD,2" -t sine -f 440 2>/dev/null || true
            ;;
        headphones)
            timeout 3 speaker-test -c2 -r48000 -D "hw:$CARD,0" -t sine -f 440 2>/dev/null || true
            ;;
    esac
    echo "Test complete"
}

toggle_audio() {
    current_device=$(get_current_device)
    case "$current_device" in
        speakers)
            enable_headphones
            ;;
        headphones)
            enable_speakers
            ;;
    esac
}

adjust_volume() {
    local adjustment="$1"
    device_type=$(get_current_device)
    
    case "$adjustment" in
        +)
            if [ "$device_type" = "speakers" ]; then
                wpctl set-volume $SPEAKER_DEVICE 5%+ >/dev/null 2>&1
            else
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%')
                new_vol=$((current_vol + 5))
                [ $new_vol -gt 100 ] && new_vol=100
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' "${new_vol}%" >/dev/null
            fi
            echo "Volume increased"
            ;;
        -)
            if [ "$device_type" = "speakers" ]; then
                wpctl set-volume $SPEAKER_DEVICE 5%- >/dev/null 2>&1
            else
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%')
                new_vol=$((current_vol - 5))
                [ $new_vol -lt 0 ] && new_vol=0
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' "${new_vol}%" >/dev/null
            fi
            echo "Volume decreased"
            ;;
        [0-9]*)
            if [ "$device_type" = "speakers" ]; then
                wpctl set-volume $SPEAKER_DEVICE "${adjustment}%" >/dev/null 2>&1
            else
                amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' "${adjustment}%" >/dev/null
            fi
            echo "Volume set to ${adjustment}%"
            ;;
        *)
            if [ "$device_type" = "speakers" ]; then
                current_vol=$(wpctl get-volume $SPEAKER_DEVICE 2>/dev/null | awk '{print int($2*100)}' || echo "0")
            else
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%')
            fi
            echo "Current $device_type volume: ${current_vol}%"
            ;;
    esac
}

mute_device() {
    device_type=$(get_current_device)
    case "$device_type" in
        speakers)
            wpctl set-mute $SPEAKER_DEVICE 1 >/dev/null 2>&1
            echo "Speakers muted"
            ;;
        headphones)
            amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 0% >/dev/null
            echo "Headphones muted"
            ;;
    esac
}

unmute_device() {
    device_type=$(get_current_device)
    case "$device_type" in
        speakers)
            wpctl set-mute $SPEAKER_DEVICE 0 >/dev/null 2>&1
            echo "Speakers unmuted"
            ;;
        headphones)
            amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 50% >/dev/null
            echo "Headphones unmuted"
            ;;
    esac
}

check_dependencies
check_card

case "${1:-}" in
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
        adjust_volume "${2:-}"
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
