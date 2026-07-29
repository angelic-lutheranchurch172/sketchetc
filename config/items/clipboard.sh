#!/bin/bash
widget_on clipboard || return 0
source "$CONFIG_DIR/plugins/storage_lib.sh"
sketchybar --add event clip_hotkey
sketchybar --add event clip_captured
sketchybar --add item clipboard right \
  --set clipboard \
    update_freq=1 \
    icon=$ICON_CLIP \
    icon.color=$WHITE \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/clipboard.sh" \
  --subscribe clipboard clip_hotkey clip_captured mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global

start_clip_watch() {
  local pid_file="${TMPDIR:-/tmp}/sketchybar_clip_watch.pid"
  if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file" 2>/dev/null)" 2>/dev/null; then
    return
  fi
  nohup "$CONFIG_DIR/plugins/bin/clip_watch" "$(clip_dir)" > /dev/null 2>&1 &
  echo $! > "$pid_file"
}
start_clip_watch
