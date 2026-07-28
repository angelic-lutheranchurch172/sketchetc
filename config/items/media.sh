#!/bin/bash
widget_on media || return 0
sketchybar --add item media right \
  --set media \
    update_freq=5 \
    icon=$ICON_MEDIA \
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
  --set media.prev icon=$ICON_PREV $CTL_PROPS click_script="$PLUGIN_DIR/media_ctl.sh prev" \
  --add item media.play popup.media \
  --set media.play icon=$ICON_PLAY $CTL_PROPS icon.color=$PINK click_script="$PLUGIN_DIR/media_ctl.sh playpause" \
  --add item media.next popup.media \
  --set media.next icon=$ICON_NEXT $CTL_PROPS click_script="$PLUGIN_DIR/media_ctl.sh next" \
  --add item media.progress popup.media \
  --set media.progress icon.drawing=off background.drawing=off drawing=off \
    label.font="JetBrainsMono Nerd Font:Regular:11.0" label.padding_right=10
