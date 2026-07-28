#!/bin/bash
# Opens the journal window (runs DETACHED from sketchybar so it can live long).
# On finalize, locks today's entry via journal_lib.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export CONFIG_DIR
source "$CONFIG_DIR/plugins/journal_lib.sh"

[ -z "$(jroot)" ] && exit 0
[ -f "$(jtoday_file)" ] && { osascript -e 'display notification "Today is already locked. Check History in the journal window." with title "Journal"'; }

OUT=$("$CONFIG_DIR/plugins/bin/journal_win" "$JDRAFT" "$(jroot)")
if [ "$OUT" = "FINALIZE" ]; then
  if [ -f "$(jtoday_file)" ]; then
    osascript -e 'display notification "Today was already locked, draft kept for tomorrow" with title "Journal"'
  else
    jfinalize
  fi
fi
