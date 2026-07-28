#!/bin/bash
# Permanent 1s watcher (no background processes — children spawned from
# sketchybar plugins don't survive). Two jobs:
#   1. Close all popups when a click happens outside the bar/popup zone
#      (global click counter + cursor position via mouse_info; read-only APIs).
#   2. While the volume popup is open, sync slider knob -> system volume
#      several times within the tick so dragging feels live.
BIN="$CONFIG_DIR/plugins/bin/mouse_info"
[ -x "$BIN" ] || exit 0
STATE="${TMPDIR:-/tmp}/sketchybar_clickwatch"

popup_open() {
  sketchybar --query "$1" 2>/dev/null | awk '/"popup"/ {getline l; exit !(l ~ /"on"/)}'
}

OPEN_ITEM=""
for it in apple clock ram cpu battery wifi volume ai_agents media front_app network ports github clipboard aura journal theme_picker widgets_menu; do
  popup_open "$it" && OPEN_ITEM="$it" && break
done

read -r _ Y CLICKS _ _ < <("$BIN")

if [ -z "$OPEN_ITEM" ]; then
  echo "$CLICKS" > "$STATE"
  exit 0
fi

LAST=$(cat "$STATE" 2>/dev/null || echo "$CLICKS")
echo "$CLICKS" > "$STATE"

# any click below the bar closes popups; clicking a popup row still runs its
# click_script first (close follows on the next tick). The volume popup gets a
# taller protected zone so slider dragging isn't cut short.
ZONE=30
[ "$OPEN_ITEM" = "volume" ] && ZONE=150
ZONE="${CLICKWATCH_ZONE:-$ZONE}"

if [ "$CLICKS" -gt "${LAST:-$CLICKS}" ] && [ "$Y" -gt "$ZONE" ]; then
  sketchybar --set "/.*/" popup.drawing=off
  exit 0
fi

# live volume while its popup is open: ~6 sub-ticks inside this 1s tick
if [ "$OPEN_ITEM" = "volume" ]; then
  LASTP=-1
  for _ in 1 2 3 4 5 6; do
    P=$(sketchybar --query volume.slider 2>/dev/null | awk -F'[:,]' '/"percentage"/ {gsub(/[^0-9]/,"",$2); print $2; exit}')
    if [ -n "$P" ] && [ "$P" != "$LASTP" ]; then
      osascript -e "set volume output volume $P"
      LASTP=$P
    fi
    sleep 0.15
  done
fi
exit 0
