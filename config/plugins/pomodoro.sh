#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

STATE="${TMPDIR:-/tmp}/sketchybar_pomo"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE" ]; then
    rm -f "$STATE"
  else
    echo $(( $(date +%s) + 1500 )) > "$STATE"   # 25 min
  fi
fi

if [ ! -f "$STATE" ]; then
  sketchybar --set "$NAME" icon=󰔛 icon.color=$WHITE label.drawing=off
  exit 0
fi

REM=$(( $(cat "$STATE") - $(date +%s) ))
if [ "$REM" -le 0 ]; then
  rm -f "$STATE"
  osascript -e 'display notification "25 minutes done — take a break" with title "Pomodoro" sound name "Glass"'
  say -v Samantha "Pomodoro complete. Take a break." &
  sketchybar --set "$NAME" icon=󰔛 icon.color=$WHITE label.drawing=off
  exit 0
fi

COLOR=$PINK
[ "$REM" -le 60 ] && COLOR=$RED
sketchybar --set "$NAME" icon=󰔛 icon.color=$COLOR label.drawing=on \
  label="$(printf '%02d:%02d' $((REM / 60)) $((REM % 60)))" label.color=$COLOR
