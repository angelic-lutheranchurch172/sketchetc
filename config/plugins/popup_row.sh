#!/bin/bash
# hover highlight for popup menu rows + tooltip text-swap.
# Rows write hint text to $TMPDIR/sketchybar_hint_<rowname> at creation; the
# parent popup owns an always-drawn "<parent>.hint" line whose TEXT we swap
# (visibility toggling mid-display doesn't re-layout popups reliably).
source "$CONFIG_DIR/colors.sh"

PARENT="${NAME%%.*}"
HINT_FILE="${TMPDIR:-/tmp}/sketchybar_hint_$NAME"

case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" background.drawing=on background.color=$ITEM_BG_COLOR
    if [ -f "$HINT_FILE" ]; then
      sketchybar --set "$PARENT.hint" label="$(cat "$HINT_FILE")" label.color=$CYAN 2>/dev/null
    fi
    ;;
  mouse.exited)
    sketchybar --set "$NAME" background.drawing=off
    sketchybar --set "$PARENT.hint" label="hover an option" label.color=0x44ffffff 2>/dev/null
    ;;
esac
