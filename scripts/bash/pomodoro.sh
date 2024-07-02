#!/run/current-system/sw/bin/bash

STATE_FILE="/tmp/pomodoro_state"

# Check if the state file exists
if [ ! -f "$STATE_FILE" ]; then
  echo "Pomodoro: Inactive"
  exit 0
fi

# Read the state and start time
read state start_time < "$STATE_FILE"

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
    remaining_time=$REST_TIME_SEC
  else
    remaining_time=$((WORK_TIME_SEC - elapsed_time))
  fi
else
  if [ "$elapsed_time" -ge "$REST_TIME_SEC" ]; then
    state="WORK"
    start_time=$(date +%s)
    echo "WORK $start_time" > "$STATE_FILE"
    remaining_time=$WORK_TIME_SEC
  else
    remaining_time=$((REST_TIME_SEC - elapsed_time))
  fi
fi

minutes=$((remaining_time / 60))
seconds=$((remaining_time % 60))

if [ "$state" == "WORK" ]; then
  echo "Work: $minutes:$seconds"
else
  echo "Rest: $minutes:$seconds"
fi

