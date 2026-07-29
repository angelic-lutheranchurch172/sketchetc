#!/bin/bash
widget_on network || return 0
sketchybar --add item network right \
  --set network \
    width=112 \
    update_freq=2 \
    icon=$ICON_NET \
    icon.color=$CYAN \
    label.font="JetBrainsMono Nerd Font:Bold:11.0" \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/network.sh" \
  --subscribe network mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
