#!/bin/bash
sketchybar --add item clock right \
  --set clock \
    update_freq=10 \
    icon=$ICON_CLOCK \
    icon.color=$CYAN \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/clock.sh" \
  --subscribe clock mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
