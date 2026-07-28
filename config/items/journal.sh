#!/bin/bash
widget_on journal || return 0
sketchybar --add item journal right \
  --set journal \
    update_freq=300 \
    icon=$ICON_JOURNAL \
    icon.color=$WHITE \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/journal.sh" \
  --subscribe journal mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
