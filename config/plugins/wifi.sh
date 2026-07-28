#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  IP=$(ipconfig getifaddr en0 2>/dev/null)
  sketchybar --set wifi.ip label="${IP:-not connected}"
  toggle_popup
  exit 0
fi

# ponytail: macOS 26 redacts SSID from CLI without Location Services · show connectivity only
if ipconfig getifaddr en0 >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon=$ICON_WIFI icon.color=$CYAN label.drawing=off
else
  sketchybar --set "$NAME" icon=$ICON_WIFI_OFF icon.color=$RED label="off" label.drawing=on
fi
