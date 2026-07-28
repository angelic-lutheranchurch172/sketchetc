#!/bin/bash
widget_on speedtest || return 0
sketchybar --add item speedtest right \
  --set speedtest \
    update_freq=2 \
    icon=󰓅 \
    icon.color=$WHITE \
    label.drawing=off \
    script="$PLUGIN_DIR/speedtest.sh" \
  --subscribe speedtest mouse.entered mouse.exited mouse.clicked
