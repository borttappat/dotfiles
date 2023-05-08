#!/bin/sh
# autostart xdotools commands
i3-msg workspace 1
sleep 1
xdotool key super+enter
sleep 1
xdotool type "fetch"
xdotool key enter
sleep 1
xdotool key super+enter
sleep 1
xdotool type "htop"
xdotool key enter
sleep 1
xdotool key super+h
sleep 1
xdotool key super+enter
sleep 1
xdotool type "chatgpt"
xdotool key enter
sleep 1
xdotool key super+enter
sleep 1
xdotool type "ranger"
xdotool key enter
sleep 1
xdotool key super+Left
