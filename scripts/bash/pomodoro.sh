#!/run/current-system/sw/bin/bash

STATE_FILE="/tmp/pomodoro_state"
PAUSE_FILE="/tmp/pomodoro_pause"

# Check if the state file exists
if [ ! -f "$STATE_FILE" ] && [ ! -f "$PAUSE_FILE" ]; then
  echo "Inactive"
  exit 0
fi

# Read the state and start time
if [ -f "$STATE_FILE" ]; then
  read state start_time < "$STATE_FILE"
elif [ -f "$PAUSE_FILE" ]; then
  read state start_time < "$PAUSE_FILE"
fi

WORK_TIME=25  # Work time in minutes
REST_TIME=5   # Rest time in minutes

# Convert minutes to seconds
WORK_TIME_SEC=$((WORK_TIME * 60))
REST_TIME_SEC=$((REST_TIME * 60))

current_time=$(date +%s)
elapsed_time=$((current_time - start_time))

if [ "$state" == "WORK" ]; then
  if [ "$elapsed_time" -ge "$WORK_TIME_SEC" ]; then
    state="REST"
    start_time=$(date +%s)
    echo "REST $start_time" > "$STATE_FILE"
    i3-msg 'exec --no-startup-id alacritty --class pomo -e sh -c "echo Time to rest! && read"'
    sleep 0.5
    i3-msg '[class="^pomo$"] floating enable; resize set width 300px height 100px; move position center'
    remaining_time=$REST_TIME_SEC
  else
    remaining_time=$((WORK_TIME_SEC - elapsed_time))
  fi
else
  if [ "$elapsed_time" -ge "$REST_TIME_SEC" ]; then
    state="WORK"
    start_time=$(date +%s)
    echo "WORK $start_time" > "$STATE_FILE"
    i3-msg 'exec --no-startup-id alacritty --class pomo -e sh -c "echo Time to work! && read"'
    sleep 0.5
    i3-msg '[class="^pomo$"] floating enable; resize set width 300px height 100px; move position center'
    remaining_time=$WORK_TIME_SEC
  else
    remaining_time=$((REST_TIME_SEC - elapsed_time))
  fi
fi

minutes=$((remaining_time / 60))
seconds=$((remaining_time % 60))

# Ensure two-digit formatting
formatted_minutes=$(printf "%02d" $minutes)
formatted_seconds=$(printf "%02d" $seconds)

if [ -f "$PAUSE_FILE" ]; then
  echo "Paused $formatted_minutes:$formatted_seconds"
else
  if [ "$state" == "WORK" ]; then
    echo "Work $formatted_minutes:$formatted_seconds"
  else
    echo "Rest $formatted_minutes:$formatted_seconds"
  fi
fi

