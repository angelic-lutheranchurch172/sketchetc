#!/bin/bash
widget_on github || return 0
sketchybar --add item github right \
  --set github \
    width=64 \
    update_freq=300 \
    icon=󰊤 \
    icon.color=$WHITE \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/github.sh" \
  --subscribe github mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
