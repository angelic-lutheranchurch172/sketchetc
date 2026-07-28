#!/bin/bash
# numeric volume entry (0-100)
source "$CONFIG_DIR/colors.sh"
sketchybar --set volume popup.drawing=off
V=$(osascript -e 'text returned of (display dialog "Volume (0-100):" default answer "" with title "Volume")' 2>/dev/null)
[[ "$V" =~ ^[0-9]+$ ]] || exit 0
[ "$V" -gt 100 ] && V=100
osascript -e "set volume output volume $V"
sketchybar --set volume.slider slider.percentage="$V"
