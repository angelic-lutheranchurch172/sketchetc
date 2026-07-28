#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$BUTTON" = "right" ]; then
    toggle_popup
  else
    "$CONFIG_DIR/plugins/media_ctl.sh" playpause
  fi
  exit 0
fi

# ponytail: polls Spotify then Music via osascript; media_change event is broken on macOS 15.4+
track=""
if pgrep -xq Spotify; then
  track=$(osascript -e 'tell application "Spotify" to if player state is playing then (get name of current track) & " — " & (get artist of current track)' 2>/dev/null)
elif pgrep -xq Music; then
  track=$(osascript -e 'tell application "Music" to if player state is playing then (get name of current track) & " — " & (get artist of current track)' 2>/dev/null)
fi

if [ -n "$track" ]; then
  sketchybar --set "$NAME" drawing=on label="$track"
else
  sketchybar --set "$NAME" drawing=off
fi
