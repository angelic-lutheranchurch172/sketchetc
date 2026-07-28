#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$BUTTON" = "right" ]; then
    # progress snapshot: elapsed ▰▰▰▱▱ total
    APP=""
    pgrep -xq Spotify && APP="Spotify"
    [ -z "$APP" ] && pgrep -xq Music && APP="Music"
    if [ -n "$APP" ]; then
      if [ "$APP" = "Spotify" ]; then
        read -r POS DUR < <(osascript -e 'tell application "Spotify" to get (player position as integer) & " " & (duration of current track) / 1000 as integer' 2>/dev/null | tr ',' ' ')
      else
        read -r POS DUR < <(osascript -e 'tell application "Music" to get (player position as integer) & " " & (duration of current track as integer)' 2>/dev/null | tr ',' ' ')
      fi
      if [ -n "$POS" ] && [ -n "$DUR" ] && [ "$DUR" -gt 0 ]; then
        FILL=$((POS * 10 / DUR))
        BAR=$(printf '▰%.0s' $(seq 1 $((FILL == 0 ? 1 : FILL))))$(printf '▱%.0s' $(seq 1 $((10 - (FILL == 0 ? 1 : FILL)))))
        sketchybar --set media.progress drawing=on \
          label="$(printf '%d:%02d %s %d:%02d' $((POS/60)) $((POS%60)) "$BAR" $((DUR/60)) $((DUR%60)))"
      fi
    fi
    toggle_popup
  else
    "$CONFIG_DIR/plugins/media_ctl.sh" playpause
  fi
  exit 0
fi

# ponytail: polls Spotify then Music via osascript; media_change event is broken on macOS 15.4+
track=""
if pgrep -xq Spotify; then
  track=$(osascript -e 'tell application "Spotify" to if player state is playing then (get name of current track) & " · " & (get artist of current track)' 2>/dev/null)
elif pgrep -xq Music; then
  track=$(osascript -e 'tell application "Music" to if player state is playing then (get name of current track) & " · " & (get artist of current track)' 2>/dev/null)
fi

if [ -n "$track" ]; then
  sketchybar --set "$NAME" drawing=on label="$track"
else
  sketchybar --set "$NAME" drawing=off
fi
