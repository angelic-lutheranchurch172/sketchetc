#!/bin/bash
# hover highlight for popup menu rows
source "$CONFIG_DIR/colors.sh"
case "$SENDER" in
  mouse.entered) sketchybar --set "$NAME" background.drawing=on background.color=$ITEM_BG_COLOR ;;
  mouse.exited)  sketchybar --set "$NAME" background.drawing=off ;;
esac
