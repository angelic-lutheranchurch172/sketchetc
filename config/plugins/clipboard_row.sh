#!/bin/bash
# Dual duty: hover handler for clipboard rows (image preview) + paste action.
source "$CONFIG_DIR/colors.sh"

if [ "$1" = "paste" ]; then
  FILE="$2"
  if [[ "$FILE" == *.png ]]; then
    osascript -e "set the clipboard to (read (POSIX file \"$FILE\") as «class PNGf»)"
  else
    pbcopy < "$FILE"
  fi
  sketchybar --set clipboard popup.drawing=off
  sleep 0.15
  # try to paste into the frontmost app; harmless no-op without Accessibility
  osascript -e 'tell application "System Events" to keystroke "v" using command down' 2>/dev/null \
    || osascript -e 'display notification "Copied · press ⌘V to paste" with title "Clipboard"'
  exit 0
fi

# hover: for image rows, show/hide the large preview
IDX="${NAME##*.}"
FILE=$(cat "${TMPDIR:-/tmp}/sketchybar_clip_$IDX" 2>/dev/null)
case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" background.drawing=on background.color=$ITEM_BG_COLOR
    if [[ "$FILE" == *.png ]]; then
      sketchybar --set clipboard.row.preview drawing=on \
        background.image="$FILE" background.image.scale=0.25 background.image.corner_radius=8
    fi
    ;;
  mouse.exited)
    sketchybar --set "$NAME" background.drawing=off
    sketchybar --set clipboard.row.preview drawing=off
    ;;
esac
