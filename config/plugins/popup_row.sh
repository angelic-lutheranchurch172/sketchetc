#!/bin/bash
# hover highlight + tooltip for popup rows, flicker-free:
# - highlight = color swap on an always-drawn background (no size change)
# - hint text swaps directly between rows; it only CLEARS after a 250ms
#   debounce with no other row entered (kills the blank-blink between rows
#   and the enter/exit ordering race)
source "$CONFIG_DIR/colors.sh"

PARENT="${NAME%%.*}"
HINT_FILE="${TMPDIR:-/tmp}/sketchybar_hint_$NAME"
CURRENT="${TMPDIR:-/tmp}/sketchybar_hintcur_$PARENT"

case "$SENDER" in
  mouse.entered)
    echo "$NAME" > "$CURRENT"
    sketchybar --set "$NAME" background.color=$ITEM_BG_COLOR
    if [ -f "$HINT_FILE" ]; then
      sketchybar --set "$PARENT.hint" label="$(cat "$HINT_FILE")" label.color=$CYAN 2>/dev/null
    fi
    ;;
  mouse.exited)
    sketchybar --set "$NAME" background.color=$TRANSPARENT
    sleep 0.25
    # only clear if the cursor didn't land on another row meanwhile
    if [ "$(cat "$CURRENT" 2>/dev/null)" = "$NAME" ]; then
      sketchybar --set "$PARENT.hint" label="" 2>/dev/null
    fi
    ;;
esac
