#!/bin/bash
sketchybar --add item volume right \
  --set volume \
    icon=$ICON_VOL_HI \
    icon.color=$PINK \
    $POPUP_PROPS \
    popup.align=right \
    popup.height=34 \
    script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change mouse.entered mouse.exited mouse.clicked mouse.scrolled mouse.entered.global mouse.exited.global

sketchybar --add slider volume.slider popup.volume 140 \
  --set volume.slider \
    slider.highlight_color=$PINK \
    slider.background.height=8 \
    slider.background.corner_radius=4 \
    slider.background.color=$ITEM_BG_COLOR \
    slider.knob=󰝥 \
    slider.knob.color=$CYAN \
    icon.drawing=off label.drawing=off \
    script="$PLUGIN_DIR/volume_slider.sh" \
  --subscribe volume.slider mouse.clicked
