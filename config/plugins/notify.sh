#!/bin/bash
# notify.sh <category> <title> <message>
# Categories are gated by settings.conf (notify_<category>=on|off); `sound=off`
# silences the chime. Unknown/blank category always notifies.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
SETTINGS="$CONFIG_DIR/settings.conf"

setting() { awk -F= -v k="$1" '$1 == k {print $2; exit}' "$SETTINGS" 2>/dev/null; }

CAT="$1" TITLE="$2" MSG="$3"
# back-compat: two-arg calls are (title, message) with no category
if [ -z "$MSG" ]; then TITLE="$1"; MSG="$2"; CAT=""; fi

if [ -n "$CAT" ]; then
  V=$(setting "notify_$CAT")
  [ "$V" = "off" ] && exit 0
fi

if [ "$(setting sound)" = "off" ]; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\""
  exit 0
fi

CUSTOM=$(cat "$CONFIG_DIR/.notify_sound" 2>/dev/null)
if [ -n "$CUSTOM" ] && [ -f "$CUSTOM" ]; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\""
  afplay "$CUSTOM" >/dev/null 2>&1 &
else
  osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"Glass\""
fi
