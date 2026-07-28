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

sketchybar --add slider volume.slider popup.volume 150 \
  --set volume.slider \
    slider.highlight_color=$PINK \
    slider.background.height=6 \
    slider.background.corner_radius=3 \
    slider.background.color=$ITEM_BG_COLOR \
    slider.knob=󰝥 \
    slider.knob.color=$CYAN \
    slider.knob.font="JetBrainsMono Nerd Font:Regular:14.0" \
    slider.padding_left=12 slider.padding_right=12 \
    icon.drawing=off label.drawing=off \
    script="$PLUGIN_DIR/volume_slider.sh" \
  --subscribe volume.slider mouse.clicked

sketchybar --add item volume.typed popup.volume \
  --set volume.typed icon=󰎠 icon.color=$CYAN icon.padding_left=12 \
    background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 \
    label="type a value" label.font="JetBrainsMono Nerd Font:Regular:11.0" label.padding_right=12 \
    script="$PLUGIN_DIR/popup_row.sh" \
    click_script="$PLUGIN_DIR/volume_typed.sh" \
  --subscribe volume.typed mouse.entered mouse.exited
