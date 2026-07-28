#!/bin/bash
# hover highlight for popup menu rows: color swap on an always-drawn background
source "$CONFIG_DIR/colors.sh"
case "$SENDER" in
  mouse.entered) sketchybar --set "$NAME" background.color=$ITEM_BG_COLOR ;;
  mouse.exited)  sketchybar --set "$NAME" background.color=$TRANSPARENT ;;
esac
