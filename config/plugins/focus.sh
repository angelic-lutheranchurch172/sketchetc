#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

if [ "$SENDER" = "mouse.clicked" ]; then
  if shortcuts list 2>/dev/null | grep -qix "Toggle Focus"; then
    shortcuts run "Toggle Focus"
    "$CONFIG_DIR/plugins/notify.sh" "Do Not Disturb" "Focus toggled" &
    sketchybar --animate sin 12 --set "$NAME" icon.y_offset=3 icon.y_offset=0
  else
    "$CONFIG_DIR/plugins/notify.sh" "Focus toggle" "Create a Shortcut named \"Toggle Focus\" (Set Focus → Do Not Disturb → toggle) to use this button"
    open "shortcuts://create-shortcut"
  fi
fi
exit 0
