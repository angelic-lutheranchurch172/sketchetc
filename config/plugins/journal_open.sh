#!/bin/bash
# Opens the journal window (runs DETACHED from sketchybar so it can live long).
# Passes the write-target date; locks that day on finalize.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export CONFIG_DIR
source "$CONFIG_DIR/plugins/journal_lib.sh"

[ -z "$(jroot)" ] && exit 0
TARGET=$(jtarget_date)
NICE=$(date -j -f %Y-%m-%d "$TARGET" '+%a %d %b' 2>/dev/null || echo "$TARGET")
if [ "$TARGET" = "$(date +%Y-%m-%d)" ]; then
  DEADLINE="locks tomorrow 12:00"
else
  DEADLINE="locks today 12:00"
fi

OUT=$("$CONFIG_DIR/plugins/bin/journal_win" "$JDRAFT" "$(jroot)" "Writing for $NICE · $DEADLINE")
if [ "$OUT" = "FINALIZE" ]; then
  jfinalize "$TARGET"
fi
