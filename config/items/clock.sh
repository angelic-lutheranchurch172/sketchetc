#!/bin/bash
sketchybar --add item clock right \
  --set clock \
    update_freq=10 \
    icon=$ICON_CLOCK \
    icon.color=$CYAN \
    click_script="open -a Calendar" \
    script="$PLUGIN_DIR/clock.sh" \
  --subscribe clock mouse.entered mouse.exited
