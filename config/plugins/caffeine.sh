#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

if [ "$SENDER" = "mouse.clicked" ]; then
  if pgrep -x caffeinate >/dev/null; then
    pkill -x caffeinate
  else
    # osascript's do shell script daemonizes properly (survives plugin exit)
    osascript -e 'do shell script "nohup caffeinate -di > /dev/null 2>&1 &"'
  fi
fi

if pgrep -x caffeinate >/dev/null; then
  sketchybar --set "$NAME" icon=$ICON_CAF_ON icon.color=$PINK
else
  sketchybar --set "$NAME" icon=$ICON_CAF_OFF icon.color=$WHITE
fi
