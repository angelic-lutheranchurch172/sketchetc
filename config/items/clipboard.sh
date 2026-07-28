#!/bin/bash
widget_on clipboard || return 0
sketchybar --add event clip_hotkey
sketchybar --add item clipboard right \
  --set clipboard \
    update_freq=2 \
    icon=$ICON_CLIP \
    icon.color=$WHITE \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/clipboard.sh" \
  --subscribe clipboard clip_hotkey mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
