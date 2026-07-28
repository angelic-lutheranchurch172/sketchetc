#!/bin/bash
widget_on meeting || return 0
sketchybar --add item meeting left \
  --set meeting \
    update_freq=60 \
    icon=󰤙 \
    icon.color=$PINK \
    drawing=off \
    script="$PLUGIN_DIR/meeting.sh" \
  --subscribe meeting mouse.entered mouse.exited mouse.clicked
