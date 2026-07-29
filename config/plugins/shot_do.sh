#!/bin/bash
# shot_do.sh area|areaclip|window|full|timer · CleanShot-lite via screencapture
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
OUT="$HOME/Desktop/shot-$(date +%H%M%S).png"
sleep 0.3   # let the popup close before interactive capture starts

case "$1" in
  area)     screencapture -i "$OUT" ;;
  areaclip) screencapture -ic ;;
  window)   screencapture -iw "$OUT" ;;
  full)     screencapture -x "$OUT" ;;
  timer)    screencapture -T 5 -x "$OUT" ;;
  *) exit 0 ;;
esac

if [ "$1" = "areaclip" ]; then
  "$CONFIG_DIR/plugins/notify.sh" "Screenshot" "Copied to clipboard"
elif [ -s "$OUT" ]; then
  "$CONFIG_DIR/plugins/notify.sh" "Screenshot" "Saved to Desktop"
  open -R "$OUT"
else
  rm -f "$OUT"
fi
