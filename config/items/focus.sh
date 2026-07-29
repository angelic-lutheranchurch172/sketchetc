#!/bin/bash
widget_on focus || return 0
sketchybar --add item focus right \
  --set focus \
    width=32 \
    icon=$ICON_FOCUS \
    icon.color=$WHITE \
    icon.padding_left=7 icon.padding_right=7 \
    label.drawing=off \
    script="$PLUGIN_DIR/focus.sh" \
  --subscribe focus mouse.entered mouse.exited mouse.clicked
