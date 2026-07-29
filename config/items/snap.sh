#!/bin/bash
widget_on snap || return 0
sketchybar --add item snap right \
  --set snap \
    width=32 \
    icon=$ICON_SNAP \
    icon.color=$CYAN \
    icon.padding_left=7 icon.padding_right=7 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=right \
    script="$PLUGIN_DIR/snap.sh" \
  --subscribe snap mouse.entered mouse.exited mouse.clicked mouse.entered.global mouse.exited.global

snap_row() { # name icon label mode
  sketchybar --add item "snap.$1" popup.snap \
    --set "snap.$1" icon="$2" icon.color=$CYAN icon.padding_left=10 \
      background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 width=220 \
      label="$3" label.font="JetBrainsMono Nerd Font:Regular:12.0" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="$CONFIG_DIR/plugins/snap_do.sh $4; sketchybar --set snap popup.drawing=off" \
    --subscribe "snap.$1" mouse.entered mouse.exited
}
snap_row lhalf  󰧀 "Left half"    left
snap_row rhalf  󰧂 "Right half"   right
snap_row thalf  󰧁 "Top half"     top
snap_row bhalf  󰧅 "Bottom half"  bottom
snap_row l3     󰡎 "Left third"   l3
snap_row m3     󰡏 "Middle third" m3
snap_row r3     󰡐 "Right third"  r3
snap_row max    󰊓 "Maximize"     max
snap_row center 󱂬 "Center"       center
