#!/bin/bash
sketchybar --add item media right \
  --set media \
    update_freq=5 \
    icon=󰝚 \
    icon.color=$PINK \
    label.max_chars=18 \
    scroll_texts=on \
    drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    popup.horizontal=on \
    script="$PLUGIN_DIR/media.sh" \
  --subscribe media mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global

CTL_PROPS="label.drawing=off icon.padding_left=10 icon.padding_right=10 icon.color=$CYAN background.drawing=off"

sketchybar --add item media.prev popup.media \
  --set media.prev icon=󰒮 $CTL_PROPS click_script="$PLUGIN_DIR/media_ctl.sh prev" \
  --add item media.play popup.media \
  --set media.play icon=󰐊 $CTL_PROPS icon.color=$PINK click_script="$PLUGIN_DIR/media_ctl.sh playpause" \
  --add item media.next popup.media \
  --set media.next icon=󰒭 $CTL_PROPS click_script="$PLUGIN_DIR/media_ctl.sh next"
