#!/bin/bash
# shot_do.sh area|areaclip|window|full|timer · CleanShot-lite via screencapture
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export CONFIG_DIR
source "$CONFIG_DIR/plugins/settings_lib.sh"

DIR=$(setting shot_dir)
case "$DIR" in ""|DESKTOP) DIR="$HOME/Desktop" ;; esac
mkdir -p "$DIR" 2>/dev/null
OUT="$DIR/shot-$(date +%Y%m%d-%H%M%S).png"
sleep 0.3   # let the popup close before an interactive capture starts

# Interactive captures can take as long as the user needs, so callers launch
# this script detached; it must not be tied to a click_script's lifetime.
case "$1" in
  area)     screencapture -i "$OUT" ;;
  areaclip) screencapture -ic ;;
  window)   screencapture -iw "$OUT" ;;
  full)     screencapture -x "$OUT" ;;
  timer)    screencapture -T 5 -x "$OUT" ;;
  *) exit 0 ;;
esac

if [ "$1" = "areaclip" ]; then
  "$CONFIG_DIR/plugins/notify.sh" shot "Screenshot" "Copied to clipboard"
elif [ -s "$OUT" ]; then
  # shots are usually taken to share: put it on the clipboard too, which also
  # lands it at the top of our clipboard history via the watcher
  if setting_on shot_to_clipboard; then
    osascript -e "set the clipboard to (read (POSIX file \"$OUT\") as «class PNGf»)" 2>/dev/null
    "$CONFIG_DIR/plugins/notify.sh" shot "Screenshot" "Saved and copied to clipboard"
  else
    "$CONFIG_DIR/plugins/notify.sh" shot "Screenshot" "Saved to $(basename "$DIR")"
  fi
  open -R "$OUT"
else
  rm -f "$OUT"
fi
