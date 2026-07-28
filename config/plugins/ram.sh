#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/ram.top\..*/' 2>/dev/null
  sketchybar --add item ram.top.head popup.ram \
    --set ram.top.head icon.drawing=off background.drawing=off label="Top memory" \
      label.color=0xffff6ec7 label.font="JetBrainsMono Nerd Font:Bold:13.0" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -amcxo rss=,comm= | head -5 | while read -r rss comm; do
    i=$((i + 1))
    sketchybar --add item "ram.top.$i" popup.ram \
      --set "ram.top.$i" icon.drawing=off background.drawing=off \
        label="$(printf '%-18.18s %5d MB' "$(basename "$comm")" $((rss / 1024)))" \
        label.font="JetBrainsMono Nerd Font:Regular:12.0" \
        label.padding_left=12 label.padding_right=12
  done
  sketchybar --add item ram.top.clear popup.ram \
    --set ram.top.clear icon=󰃢 icon.color=0xffff6ec7 icon.padding_left=12 \
      background.drawing=off background.corner_radius=6 \
      label="Clear RAM" label.color=0xffff6ec7 \
      label.font="JetBrainsMono Nerd Font:Bold:12.0" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="sketchybar --set ram popup.drawing=off; $CONFIG_DIR/plugins/ram_reclaim.sh &" \
    --subscribe ram.top.clear mouse.entered mouse.exited
  toggle_popup
  exit 0
fi

FREE=$(memory_pressure -Q | awk '/free percentage/ {gsub("%",""); print $NF}')
USED=$((100 - FREE))

ICOLOR=0xffff6ec7 LCOLOR=0xffe8e6f0
[ "$USED" -gt 70 ] && ICOLOR=0xffffa552 LCOLOR=0xffffa552
[ "$USED" -gt 85 ] && ICOLOR=0xffff5577 LCOLOR=0xffff5577

sketchybar --set "$NAME" label="${USED}%" label.color=$LCOLOR icon.color=$ICOLOR
