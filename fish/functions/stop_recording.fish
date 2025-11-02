function stop_recording
    # Check if currently in a recording session
    if set -q RECORDING_ACTIVE
        echo "🛑 Stopping recording..."
        echo "   Press Ctrl+D or type 'exit' to finish this session"
        
        # Remove flag so new terminals don't record
        if test -f ~/.recording_active
            rm ~/.recording_active
        end
        
        # Exit the current asciinema session
        exit
    else if test -f ~/.recording_active
        # Flag exists but not in active session
        rm ~/.recording_active
        echo "[!] Recording disabled for new terminals"
    else
        echo "[!] Recording was not active"
    end
end
