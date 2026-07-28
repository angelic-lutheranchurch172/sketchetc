#!/bin/bash
widget_on ports || return 0
sketchybar --add item ports right \
  --set ports \
    update_freq=5 \
    icon=$ICON_PORTS \
    icon.color=$ORANGE \
    drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/ports.sh" \
  --subscribe ports mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
