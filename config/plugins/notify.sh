#!/bin/bash
# notify.sh <title> <message> · user-chosen sound file, system default fallback
TITLE="$1" MSG="$2"
CUSTOM=$(cat "$HOME/.config/sketchybar/.notify_sound" 2>/dev/null)
if [ -n "$CUSTOM" ] && [ -f "$CUSTOM" ]; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\""
  afplay "$CUSTOM" >/dev/null 2>&1 &
else
  osascript -e "display notification \"$MSG\" with title \"$TITLE\" sound name \"Glass\""
fi
