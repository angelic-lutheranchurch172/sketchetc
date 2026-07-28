#!/bin/bash
sketchybar --add item ai_agents right \
  --set ai_agents \
    update_freq=10 \
    icon=󰚩 \
    icon.color=$PURPLE \
    label.color=$PURPLE \
    drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/ai_agents.sh" \
  --subscribe ai_agents mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global
