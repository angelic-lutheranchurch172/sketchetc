#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

if [ "$SENDER" = "mouse.clicked" ]; then
  if shortcuts list 2>/dev/null | grep -qix "Toggle Focus"; then
    shortcuts run "Toggle Focus"
    sketchybar --animate sin 12 --set "$NAME" icon.y_offset=3 icon.y_offset=0
  else
    osascript -e 'display notification "Create a Shortcut named \"Toggle Focus\" (Set Focus → Do Not Disturb → toggle) to use this button" with title "Focus toggle"'
    open "shortcuts://create-shortcut"
  fi
fi
exit 0
