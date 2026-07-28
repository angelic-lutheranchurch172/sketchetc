#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit
source "$CONFIG_DIR/plugins/icon_map_fn.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/front_app.app\..*/' 2>/dev/null
  i=0
  osascript -e 'tell application "System Events" to get name of every application process whose visible is true' \
    | tr ',' '\n' | sed 's/^ *//' | while IFS= read -r app; do
    [ -z "$app" ] && continue
    i=$((i + 1))
    __icon_map "$app"
    sketchybar --add item "front_app.app.$i" popup.front_app \
      --set "front_app.app.$i" icon="$icon_result" \
        icon.font="sketchybar-app-font:Regular:14.0" icon.padding_left=10 \
        label="$app" label.padding_right=12 background.corner_radius=6 background.drawing=off \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="osascript -e 'tell application \"$app\" to activate'; sketchybar --set front_app popup.drawing=off" \
      --subscribe "front_app.app.$i" mouse.entered mouse.exited
  done
  toggle_popup
  exit 0
fi

if [ "$SENDER" = "front_app_switched" ]; then
  __icon_map "$INFO"
  sketchybar --set "$NAME" label="$INFO" icon="$icon_result"
fi
