#!/bin/bash
widget_on weather || return 0
sketchybar --add item weather right \
  --set weather \
    update_freq=1800 \
    icon=$ICON_WEATHER \
    icon.color=$CYAN \
    script="$PLUGIN_DIR/weather.sh" \

