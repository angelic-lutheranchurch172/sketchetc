#!/bin/bash
# hover highlight + tooltip text-swap for popup rows.
# No drawing toggles and no size changes on hover: highlight = color swap on an
# always-drawn background, tooltip = text swap in a FIXED-WIDTH hint line.
source "$CONFIG_DIR/colors.sh"

PARENT="${NAME%%.*}"
HINT_FILE="${TMPDIR:-/tmp}/sketchybar_hint_$NAME"

case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" background.color=$ITEM_BG_COLOR
    if [ -f "$HINT_FILE" ]; then
      sketchybar --set "$PARENT.hint" label="$(cat "$HINT_FILE")" label.color=$CYAN 2>/dev/null
    fi
    ;;
  mouse.exited)
    sketchybar --set "$NAME" background.color=$TRANSPARENT
    sketchybar --set "$PARENT.hint" label="hover an option" label.color=0x44ffffff 2>/dev/null
    ;;
esac
