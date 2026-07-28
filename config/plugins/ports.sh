#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

# ponytail: fixed dev-port list; extend as needed
PORT_RE=':(300[0-9]|4200|5000|5173|8000|8080|9000)$'

listeners() {
  lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null \
    | awk -v re="$PORT_RE" '$9 ~ re {split($9,a,":"); print a[length(a)], $2, $1}' | sort -un
}

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/ports.row\..*/' 2>/dev/null
  sketchybar --add item ports.row.head popup.ports \
    --set ports.row.head icon.drawing=off background.drawing=off label="Dev servers (click to kill)" \
      label.color=$CYAN label.font="$HEAD_FONT" label.padding_left=12 label.padding_right=12
  i=0
  listeners | while read -r port pid comm; do
    i=$((i + 1))
    sketchybar --add item "ports.row.$i" popup.ports \
      --set "ports.row.$i" icon=$ICON_PORTS icon.color=$ORANGE icon.padding_left=10 \
        background.drawing=off background.corner_radius=6 \
        label=":$port · $comm (pid $pid)" label.font="$ROW_FONT" label.padding_right=12 \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="kill $pid; sketchybar --set ports popup.drawing=off" \
      --subscribe "ports.row.$i" mouse.entered mouse.exited
  done
  toggle_popup
  exit 0
fi

COUNT=$(listeners | wc -l | tr -d ' ')
if [ "$COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$COUNT"
else
  sketchybar --set "$NAME" drawing=off
fi
