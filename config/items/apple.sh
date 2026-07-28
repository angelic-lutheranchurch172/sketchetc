#!/bin/bash
sketchybar --add item apple left \
  --set apple \
    icon=󰀵 \
    icon.color=$PINK \
    icon.font="JetBrainsMono Nerd Font:Bold:17.0" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=left \
    script="$PLUGIN_DIR/apple.sh" \
  --subscribe apple mouse.clicked mouse.entered mouse.exited mouse.entered.global mouse.exited.global

ROW_PROPS="icon.padding_left=10 label.padding_right=12 background.corner_radius=6 background.drawing=off"

add_row() { # name icon label click_cmd
  sketchybar --add item "apple.$1" popup.apple \
    --set "apple.$1" icon="$2" icon.color=$CYAN label="$3" $ROW_PROPS \
      script="$PLUGIN_DIR/popup_row.sh" \
      click_script="$4; sketchybar --set apple popup.drawing=off" \
    --subscribe "apple.$1" mouse.entered mouse.exited
}

add_row about    󰍹 "About This Mac"   "open -a 'System Information'"
add_row settings 󰒓 "System Settings…" "open -a 'System Settings'"
add_row lock     󰌾 "Lock Screen"      "pmset displaysleepnow"
add_row sleep    󰐥 "Sleep"            "pmset sleepnow"
add_row reload   󰑓 "Reload SketchyBar" "sketchybar --reload"
