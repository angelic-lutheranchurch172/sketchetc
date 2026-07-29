#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

# Track OUR caffeinate only — other tools (Claude Code, CI scripts) run their
# own caffeinate; those must neither light the icon nor be killed by us.
PIDFILE="$HOME/.local/share/sketchetc/caffeine.pid"

ours_running() {
  local p
  p=$(cat "$PIDFILE" 2>/dev/null)
  [ -n "$p" ] && kill -0 "$p" 2>/dev/null && [ "$(ps -p "$p" -o comm= 2>/dev/null)" = "caffeinate" ]
}

if [ "$SENDER" = "mouse.clicked" ]; then
  if ours_running; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    osascript -e 'display notification "Mac can sleep normally again" with title "Keep awake off"' &
  else
    # osascript's do shell script daemonizes properly and hands back the pid
    P=$(osascript -e 'do shell script "nohup caffeinate -di > /dev/null 2>&1 & echo $!"')
    [ -n "$P" ] && echo "$P" > "$PIDFILE"
    osascript -e 'display notification "Display and system will stay awake" with title "Keep awake on"' &
  fi
fi

if ours_running; then
  sketchybar --set "$NAME" icon=$ICON_CAF_ON icon.color=$PINK
else
  sketchybar --set "$NAME" icon=$ICON_CAF_OFF icon.color=$WHITE
fi
