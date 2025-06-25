#!/bin/bash

set -e

CARD="sofsoundwire"
CARD_NUM=0

usage() {
    echo "ZenBook Audio Switch - Dynamic device detection"
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

ensure_card_profile() {
    local card_name=$(pactl list cards short | grep -E "sof|soundwire" | head -1 | awk '{print $2}')
    if [ -n "$card_name" ]; then
        pactl set-card-profile "$card_name" pro-audio >/dev/null 2>&1 || true
        sleep 1
    fi
}

find_device_ids() {
    local headphone_id=""
    local speaker_id=""
    local debug=${DEBUG:-0}
    
    [ "$debug" = "1" ] && echo "=== Debug: Finding device IDs ===" >&2
    
    # Get all sink IDs from wpctl status - handle box-drawing characters and asterisks
    local sink_ids=($(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E "│.*[0-9]+\." | \
                     awk '{
                         # Find the field with digits followed by a dot
                         for(i=1; i<=NF; i++) {
                             if($i ~ /^[0-9]+\.$/) {
                                 gsub(/\./, "", $i);
                                 print $i;
                                 break;
                             }
                         }
                     }'))
    
    [ "$debug" = "1" ] && echo "Found sink IDs: ${sink_ids[@]}" >&2
    
    # Check each sink ID for its profile
    for id in "${sink_ids[@]}"; do
        if [[ "$id" =~ ^[0-9]+$ ]]; then
            local profile=$(wpctl inspect "$id" 2>/dev/null | grep "device.profile.name" | cut -d'"' -f2)
            
            [ "$debug" = "1" ] && echo "ID $id has profile: $profile" >&2
            
            if [[ "$profile" == "pro-output-0" ]]; then
                headphone_id="$id"
            elif [[ "$profile" == "pro-output-2" ]]; then
                speaker_id="$id"
            fi
        fi
    done
    
    # Validate results
    if [ -z "$headphone_id" ] || [ -z "$speaker_id" ]; then
        echo "Error: Failed to find device IDs (headphones=$headphone_id, speakers=$speaker_id)" >&2
        echo "Available sinks from wpctl status:" >&2
        wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep "│" >&2
        return 1
    fi
    
    echo "$headphone_id $speaker_id"
}

check_card() {
    if ! aplay -l | grep -q "$CARD"; then
        echo "Error: $CARD sound card not found"
        exit 1
    fi
    
    ensure_card_profile
}

get_device_ids() {
    if [ -z "$HEADPHONE_DEVICE" ] || [ -z "$SPEAKER_DEVICE" ]; then
        local devices=$(find_device_ids)
        if [ $? -eq 0 ]; then
            HEADPHONE_DEVICE=$(echo $devices | awk '{print $1}')
            SPEAKER_DEVICE=$(echo $devices | awk '{print $2}')
        else
            echo "Error: Failed to find device IDs"
            exit 1
        fi
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
    get_device_ids
    echo "Switching to speakers (device $SPEAKER_DEVICE)..."
    
    amixer -c $CARD_NUM sset 'AMP1 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP2 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP3 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'AMP4 Speaker' on >/dev/null
    amixer -c $CARD_NUM sset 'cs42l43 Speaker Digital' on >/dev/null
    amixer -c $CARD_NUM sset 'Speaker' on >/dev/null 2>&1 || true
    
    amixer -c $CARD_NUM cset name='cs42l43 Speaker L Input 1' 'DP5RX1' >/dev/null
    amixer -c $CARD_NUM cset name='cs42l43 Speaker R Input 1' 'DP5RX2' >/dev/null
    
    amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 0% >/dev/null 2>&1 || true
    
    wpctl set-default $SPEAKER_DEVICE >/dev/null 2>&1
    wpctl set-volume $SPEAKER_DEVICE 50% >/dev/null 2>&1
    
    echo "✓ Switched to speakers"
}

enable_headphones() {
    get_device_ids
    echo "Switching to headphones (device $HEADPHONE_DEVICE)..."
    
    amixer -c $CARD_NUM cset name='cs42l43 Headphone L Input 1' 'DP5RX1' >/dev/null
    amixer -c $CARD_NUM cset name='cs42l43 Headphone R Input 1' 'DP5RX2' >/dev/null
    amixer -c $CARD_NUM sset 'cs42l43 Headphone Digital' 50% >/dev/null
    amixer -c $CARD_NUM sset 'Headphone' on >/dev/null 2>&1 || true
    
    wpctl set-default $HEADPHONE_DEVICE >/dev/null 2>&1
    
    echo "✓ Switched to headphones"
}

show_status() {
    get_device_ids
    echo "=== ZenBook Audio Status ==="
    echo ""
    
    device_type=$(get_current_device)
    echo "Current device: $device_type"
    echo "Dynamic devices: Headphones=$HEADPHONE_DEVICE, Speakers=$SPEAKER_DEVICE"
    
    echo ""
    echo "PipeWire status:"
    wpctl status | grep -A 10 "Sinks:" | grep -E "^\s*[0-9]+\.|^Audio" | sed 's/^/  /'
    
    echo ""
    echo "Hardware status:"
    local speaker_status=$(amixer -c $CARD_NUM sget 'cs42l43 Speaker Digital' 2>/dev/null | grep -o "\[on\]\|\[off\]" | head -1 || echo "[unknown]")
    local headphone_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' 2>/dev/null | grep "Front Left:" | awk '{print $4}' | tr -d '[]' || echo "unknown")
    echo "  Speakers: $speaker_status"
    echo "  Headphones: $headphone_vol"
    
    echo ""
    echo "Current default sink:"
    local default_sink=$(wpctl status | grep "Sinks:" -A 10 | grep "\*" | head -1)
    echo "  $default_sink"
}

test_audio() {
    device_type=$(get_current_device)
    echo "Testing $device_type..."
    echo "You should hear alternating tones in left and right channels"
    
    case "$device_type" in
        speakers)
            speaker-test -c2 -r48000 -D "hw:$CARD_NUM,2" -t wav -l 1 2>/dev/null || \
            speaker-test -c2 -r48000 -D "hw:$CARD_NUM,2" -t sine -f 440 -l 1 2>/dev/null || true
            ;;
        headphones)
            speaker-test -c2 -r48000 -D "hw:$CARD_NUM,0" -t wav -l 1 2>/dev/null || \
            speaker-test -c2 -r48000 -D "hw:$CARD_NUM,0" -t sine -f 440 -l 1 2>/dev/null || true
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
    get_device_ids
    local adjustment="$1"
    device_type=$(get_current_device)
    
    case "$adjustment" in
        +)
            if [ "$device_type" = "speakers" ]; then
                wpctl set-volume $SPEAKER_DEVICE 5%+ >/dev/null 2>&1
            else
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%' | head -1)
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
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%' | head -1)
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
                current_vol=$(amixer -c $CARD_NUM sget 'cs42l43 Headphone Digital' | grep "Front Left:" | awk '{print $4}' | tr -d '[]%' | head -1)
            fi
            echo "Current $device_type volume: ${current_vol}%"
            ;;
    esac
}

mute_device() {
    get_device_ids
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
    get_device_ids
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
