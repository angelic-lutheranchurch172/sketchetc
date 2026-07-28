#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/ram.top\..*/' 2>/dev/null
  sketchybar --add item ram.top.head popup.ram \
    --set ram.top.head icon.drawing=off background.drawing=off label="Top memory" \
      label.color=$PINK label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -amcxo rss=,comm= | head -5 | while read -r rss comm; do
    i=$((i + 1))
    sketchybar --add item "ram.top.$i" popup.ram \
      --set "ram.top.$i" icon.drawing=off background.drawing=off \
        label="$(printf '%-18.18s %5d MB' "$(basename "$comm")" $((rss / 1024)))" \
        label.font="$ROW_FONT" label.padding_left=12 label.padding_right=12
  done
  sketchybar --add item ram.top.clear popup.ram \
    --set ram.top.clear icon=$ICON_CLEAN icon.color=$PINK icon.padding_left=12 \
      background.drawing=off background.corner_radius=6 \
      label="Clear RAM" label.color=$PINK \
      label.font="JetBrainsMono Nerd Font:Bold:12.0" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="sketchybar --set ram popup.drawing=off; $CONFIG_DIR/plugins/ram_reclaim.sh &" \
    --subscribe ram.top.clear mouse.entered mouse.exited
  toggle_popup
  exit 0
fi

FREE=$(memory_pressure -Q | awk '/free percentage/ {gsub("%",""); print $NF}')
USED=$((100 - FREE))

ICOLOR=$PINK LCOLOR=$WHITE
[ "$USED" -gt 70 ] && ICOLOR=$ORANGE LCOLOR=$ORANGE
[ "$USED" -gt 85 ] && ICOLOR=$RED LCOLOR=$RED

sketchybar --set "$NAME" label="${USED}%" label.color=$LCOLOR icon.color=$ICOLOR
