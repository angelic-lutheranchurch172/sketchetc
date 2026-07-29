#!/bin/bash
widget_on speedtest || return 0
sketchybar --add item speedtest right \
  --set speedtest \
    width=120 \
    update_freq=2 \
    icon=$ICON_SPEED \
    icon.color=$WHITE \
    label.drawing=off \
    script="$PLUGIN_DIR/speedtest.sh" \
  --subscribe speedtest mouse.entered mouse.exited mouse.clicked
