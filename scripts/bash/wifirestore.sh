#!/run/current-system/sw/bin/bash

sudo airmon-ng stop wlo1mon
sudo NetworkManager
sudo wpa_supplicant -B

echo "wifi-services restored"
