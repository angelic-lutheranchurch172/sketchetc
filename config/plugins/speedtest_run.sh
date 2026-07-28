#!/bin/bash
# runs Apple's built-in networkQuality, writes result for speedtest.sh
STATE="${TMPDIR:-/tmp}/sketchybar_speed"
OUT=$(networkQuality 2>/dev/null)
DOWN=$(echo "$OUT" | awk '/Downlink capacity/ {printf "%d Mbps", $3}')
UP=$(echo "$OUT" | awk '/Uplink capacity/ {printf "%d Mbps", $3}')
if [ -n "$DOWN" ]; then
  echo "done|$DOWN|$UP|$(date +%s)" > "$STATE"
else
  rm -f "$STATE"
fi
sketchybar --update
