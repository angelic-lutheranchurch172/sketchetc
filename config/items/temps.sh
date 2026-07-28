#!/bin/bash
widget_on temps || return 0
command -v macmon >/dev/null || return 0
sketchybar --add item temps right \
  --set temps \
    update_freq=10 \
    icon=$ICON_TEMPS \
    icon.color=$CYAN \
    script="$PLUGIN_DIR/temps.sh" \
  --subscribe temps mouse.entered mouse.exited
