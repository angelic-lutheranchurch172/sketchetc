#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

STATE="${TMPDIR:-/tmp}/sketchybar_net"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/network.top\..*/' 2>/dev/null
  sketchybar --add item network.top.head popup.network \
    --set network.top.head icon.drawing=off background.drawing=off label="Top talkers" \
      label.color=$CYAN label.font="$HEAD_FONT" label.padding_left=12 label.padding_right=12
  i=0
  nettop -P -x -L 1 2>/dev/null | awk -F, 'NR>1 && $5+$6 > 0 {split($2,a,"."); printf "%s %d\n", a[1], ($5+$6)/1024}' \
    | sort -k2 -rn | head -5 | while read -r proc kb; do
    i=$((i + 1))
    sketchybar --add item "network.top.$i" popup.network \
      --set "network.top.$i" icon.drawing=off background.drawing=off \
        label="$(printf '%-18.18s %6d KB' "$proc" "$kb")" \
        label.font="$ROW_FONT" label.padding_left=12 label.padding_right=12
  done
  toggle_popup
  exit 0
fi

read -r IB OB < <(netstat -I en0 -b 2>/dev/null | tail -1 | awk '{print $7, $10}')
NOW=$(date +%s)
read -r PIB POB PT < <(cat "$STATE" 2>/dev/null || echo "$IB $OB $NOW")
echo "$IB $OB $NOW" > "$STATE"
DT=$((NOW - PT)); [ "$DT" -lt 1 ] && DT=1

fmt() { # bytes/sec -> human
  awk -v b="$1" 'BEGIN { if (b > 1048576) printf "%.1fM", b/1048576; else printf "%dK", b/1024 }'
}
DOWN=$(fmt $(( (IB - PIB) / DT )))
UP=$(fmt $(( (OB - POB) / DT )))

sketchybar --set "$NAME" label="↓$DOWN ↑$UP"
