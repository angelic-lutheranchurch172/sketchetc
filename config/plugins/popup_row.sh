#!/bin/bash
# hover highlight for popup menu rows + theme-matched tooltip support.
# A row gets a tooltip by writing its hint text to $TMPDIR/sketchybar_hint_<rowname>
# at creation; the parent popup must own a "<parent>.hint" bottom row.
source "$CONFIG_DIR/colors.sh"

PARENT="${NAME%%.*}"
HINT_FILE="${TMPDIR:-/tmp}/sketchybar_hint_$NAME"

case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" background.drawing=on background.color=$ITEM_BG_COLOR
    if [ -f "$HINT_FILE" ]; then
      sketchybar --set "$PARENT.hint" drawing=on label="$(cat "$HINT_FILE")" 2>/dev/null
    fi
    ;;
  mouse.exited)
    sketchybar --set "$NAME" background.drawing=off
    sketchybar --set "$PARENT.hint" drawing=off 2>/dev/null
    ;;
esac
