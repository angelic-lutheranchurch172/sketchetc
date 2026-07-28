#!/bin/bash
# numeric volume entry (0-100), themed single-line input
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
sketchybar --set volume popup.drawing=off
V=$("$CONFIG_DIR/plugins/bin/entry_box" --line "Volume (0-100)" "") || exit 0
V=$(echo "$V" | tr -dc '0-9')
[ -z "$V" ] && exit 0
[ "$V" -gt 100 ] && V=100
osascript -e "set volume output volume $V"
sketchybar --set volume.slider slider.percentage="$V"
