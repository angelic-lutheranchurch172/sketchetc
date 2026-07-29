#!/bin/bash
widget_on caffeine || return 0
sketchybar --add item caffeine right \
  --set caffeine \
    width=32 \
    update_freq=30 \
    icon=$ICON_CAF_OFF \
    icon.color=$WHITE \
    icon.padding_left=7 icon.padding_right=7 \
    label.drawing=off \
    script="$PLUGIN_DIR/caffeine.sh" \
  --subscribe caffeine mouse.entered mouse.exited mouse.clicked
