#!/bin/bash
sketchybar --add item battery right \
  --set battery \
    update_freq=120 \
    icon.color=$ORANGE \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery power_source_change system_woke mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
