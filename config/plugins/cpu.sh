#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/cpu.top\..*/' 2>/dev/null
  sketchybar --add item cpu.top.head popup.cpu \
    --set cpu.top.head icon.drawing=off background.drawing=off label="Top CPU" \
      label.color=0xff0bd3d3 label.font="JetBrainsMono Nerd Font:Bold:13.0" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -arcxo %cpu=,comm= | head -5 | while read -r pcpu comm; do
    i=$((i + 1))
    sketchybar --add item "cpu.top.$i" popup.cpu \
      --set "cpu.top.$i" icon.drawing=off background.drawing=off \
        label="$(printf '%-18.18s %5s%%' "$(basename "$comm")" "$pcpu")" \
        label.font="JetBrainsMono Nerd Font:Regular:12.0" \
        label.padding_left=12 label.padding_right=12
  done
  sketchybar --add item cpu.top.clear popup.cpu \
    --set cpu.top.clear icon=󰃢 icon.color=0xffff6ec7 icon.padding_left=12 \
      background.drawing=off background.corner_radius=6 \
      label="Clear RAM" label.color=0xffff6ec7 \
      label.font="JetBrainsMono Nerd Font:Bold:12.0" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="sketchybar --set cpu popup.drawing=off; $CONFIG_DIR/plugins/ram_reclaim.sh &" \
    --subscribe cpu.top.clear mouse.entered mouse.exited
  toggle_popup
  exit 0
fi

CORES=$(sysctl -n hw.ncpu)
USED=$(ps -A -o %cpu | awk -v c="$CORES" '{s+=$1} END {printf "%.0f", s/c}')

ICOLOR=0xff0bd3d3 LCOLOR=0xffe8e6f0
[ "$USED" -gt 70 ] && ICOLOR=0xffffa552 LCOLOR=0xffffa552
[ "$USED" -gt 85 ] && ICOLOR=0xffff5577 LCOLOR=0xffff5577

sketchybar --set "$NAME" label="${USED}%" label.color=$LCOLOR icon.color=$ICOLOR
