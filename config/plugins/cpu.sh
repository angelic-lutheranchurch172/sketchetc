#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/cpu.top\..*/' 2>/dev/null
  sketchybar --add item cpu.top.head popup.cpu \
    --set cpu.top.head icon.drawing=off background.drawing=off label="Top CPU" \
      label.color=$CYAN label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -arcxo %cpu=,comm= | head -5 | while read -r pcpu comm; do
    i=$((i + 1))
    sketchybar --add item "cpu.top.$i" popup.cpu \
      --set "cpu.top.$i" icon.drawing=off background.drawing=off \
        label="$(printf '%-18.18s %5s%%' "$(basename "$comm")" "$pcpu")" \
        label.font="$ROW_FONT" label.padding_left=12 label.padding_right=12
  done
  sketchybar --add item cpu.top.clear popup.cpu \
    --set cpu.top.clear icon=$ICON_CLEAN icon.color=$PINK icon.padding_left=12 \
      background.drawing=off background.corner_radius=6 \
      label="Clear RAM" label.color=$PINK \
      label.font="JetBrainsMono Nerd Font:Bold:12.0" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="sketchybar --set cpu popup.drawing=off; $CONFIG_DIR/plugins/ram_reclaim.sh &" \
    --subscribe cpu.top.clear mouse.entered mouse.exited
  toggle_popup
  exit 0
fi

CORES=$(sysctl -n hw.ncpu)
USED=$(ps -A -o %cpu | awk -v c="$CORES" '{s+=$1} END {printf "%.0f", s/c}')

ICOLOR=$CYAN LCOLOR=$WHITE
[ "$USED" -gt 70 ] && ICOLOR=$ORANGE LCOLOR=$ORANGE
[ "$USED" -gt 85 ] && ICOLOR=$RED LCOLOR=$RED

sketchybar --set "$NAME" label="${USED}%" label.color=$LCOLOR icon.color=$ICOLOR
