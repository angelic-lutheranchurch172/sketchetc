#!/bin/bash
widget_on switches || return 0
sketchybar --add item switches right \
  --set switches \
    width=32 \
    icon=$ICON_SWITCHES \
    icon.color=$PINK \
    icon.padding_left=7 icon.padding_right=7 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/switches.sh" \
  --subscribe switches mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
