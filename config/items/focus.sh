#!/bin/bash
widget_on focus || return 0
sketchybar --add item focus right \
  --set focus \
    icon=󰂛 \
    icon.color=$WHITE \
    label.drawing=off \
    script="$PLUGIN_DIR/focus.sh" \
  --subscribe focus mouse.entered mouse.exited mouse.clicked
