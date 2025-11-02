function start_recording
    set -l log_dir $argv[1]
    
    if test -z "$log_dir"
        set log_dir ~/terminal_logs
    end
    
    mkdir -p $log_dir
    
    # CREATE THE FLAG FILE - this was missing!
    echo "$log_dir" > ~/.recording_active
    
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -gx RECORDING_FILE "$log_dir/session_$timestamp.cast"
    set -gx RECORDING_ACTIVE 1
    
    echo "[!] Recording enabled - all new terminals will record"
    echo "[!] Recording to: $RECORDING_FILE"
    
    asciinema rec "$RECORDING_FILE"
    
    set -e RECORDING_ACTIVE
    set -e RECORDING_FILE
end
