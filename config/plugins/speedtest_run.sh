#!/bin/bash
# runs Apple's built-in networkQuality, writes result for speedtest.sh
STATE="${TMPDIR:-/tmp}/sketchybar_speed"
OUT=$(networkQuality 2>/dev/null)
DOWN=$(echo "$OUT" | awk '/Downlink capacity/ {printf "%d Mbps", $3}')
UP=$(echo "$OUT" | awk '/Uplink capacity/ {printf "%d Mbps", $3}')
if [ -n "$DOWN" ]; then
  echo "done|$DOWN|$UP|$(date +%s)" > "$STATE"
  "$HOME/.config/sketchybar/plugins/notify.sh" speedtest "Speedtest done" "Down $DOWN · Up $UP"
else
  rm -f "$STATE"
  "$CONFIG_DIR/plugins/notify.sh" speedtest "Speedtest failed" "Could not measure. Check the connection."
fi
sketchybar --update
