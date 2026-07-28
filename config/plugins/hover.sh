#!/bin/bash
# shared interactivity helpers — source at top of every plugin

# purple glow on hover
hover() {
  case "$SENDER" in
    mouse.entered) sketchybar --animate tanh 8 --set "$NAME" background.border_color=0xcc9b5de5; exit 0 ;;
    mouse.exited)  sketchybar --animate tanh 8 --set "$NAME" background.border_color=0x00000000; exit 0 ;;
  esac
}

# close ALL popups when mouse leaves the bar/popup entirely
close_popup_on_exit() {
  case "$SENDER" in
    mouse.exited.global)  sketchybar --set "/.*/" popup.drawing=off; exit 0 ;;
    mouse.entered.global) exit 0 ;;
  esac
}

# exclusive toggle: close every other popup, then toggle self
toggle_popup() {
  # popup's own drawing is the first key inside the "popup" block
  WAS_OPEN=$(sketchybar --query "$NAME" | awk '/"popup"/ {getline l; print (l ~ /"on"/) ? 1 : 0; exit}')
  sketchybar --set "/.*/" popup.drawing=off
  if [ "$WAS_OPEN" -eq 0 ]; then
    sketchybar --animate sin 12 --set "$NAME" icon.y_offset=3 icon.y_offset=0
    sketchybar --set "$NAME" popup.drawing=on
  fi
}
