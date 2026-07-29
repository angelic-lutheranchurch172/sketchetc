#!/bin/bash
widget_on bluetooth || return 0
command -v blueutil >/dev/null || return 0
sketchybar --add item bluetooth right \
  --set bluetooth \
    update_freq=30 \
    icon=$ICON_BT \
    icon.color=$CYAN \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/bluetooth.sh" \
  --subscribe bluetooth mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
