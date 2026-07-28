#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

if [ "$SENDER" = "mouse.clicked" ]; then
  if pgrep -x caffeinate >/dev/null; then
    pkill -x caffeinate
    osascript -e 'display notification "Mac can sleep normally again" with title "Keep awake off"' &
  else
    # osascript's do shell script daemonizes properly (survives plugin exit)
    osascript -e 'do shell script "nohup caffeinate -di > /dev/null 2>&1 &"'
    osascript -e 'display notification "Display and system will stay awake" with title "Keep awake on"' &
  fi
fi

if pgrep -x caffeinate >/dev/null; then
  sketchybar --set "$NAME" icon=$ICON_CAF_ON icon.color=$PINK
else
  sketchybar --set "$NAME" icon=$ICON_CAF_OFF icon.color=$WHITE
fi
