#!/bin/bash
# hover highlight for popup menu rows
case "$SENDER" in
  mouse.entered) sketchybar --set "$NAME" background.drawing=on background.color=0x409b5de5 ;;
  mouse.exited)  sketchybar --set "$NAME" background.drawing=off ;;
esac
