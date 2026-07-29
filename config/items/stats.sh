#!/bin/bash
sketchybar --add item ram right \
  --set ram \
    width=64 \
    update_freq=4 \
    icon=$ICON_RAM \
    icon.color=$PINK \
    background.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/ram.sh" \
  --subscribe ram mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global

sketchybar --add item cpu right \
  --set cpu \
    width=64 \
    update_freq=4 \
    icon=$ICON_CPU \
    icon.color=$CYAN \
    background.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/cpu.sh" \
  --subscribe cpu mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global

# shared neon pill around cpu + ram
sketchybar --add bracket stats cpu ram \
  --set stats \
    background.color=$ITEM_BG_COLOR \
    background.corner_radius=8 \
    background.height=24 \
    background.border_width=1 \
    background.border_color=0x669b5de5
