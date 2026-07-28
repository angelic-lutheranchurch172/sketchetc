#!/bin/bash
sketchybar --add item front_app left \
  --set front_app \
    icon.font="sketchybar-app-font:Regular:16.0" \
    icon.color=$CYAN \
    label.font="JetBrainsMono Nerd Font:Bold:12.0" \
    $POPUP_PROPS \
    popup.align=left \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
