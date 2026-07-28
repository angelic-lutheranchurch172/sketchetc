#!/bin/bash
widget_on aura || return 0
sketchybar --add item aura right \
  --set aura \
    update_freq=1800 \
    icon=$ICON_AURA \
    icon.color=$PURPLE \
    label.font="JetBrainsMono Nerd Font:Bold:12.0" \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/aura.sh" \
  --subscribe aura mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
