#!/bin/bash
# Permanent 1s watcher, kept deliberately CHEAP (no queries when idle).
# Marker file "<item> <clicks-at-open>" is written by toggle_popup; any click
# AFTER open with the cursor below the bar/popup zone closes the popup.
BIN="$CONFIG_DIR/plugins/bin/mouse_info"
[ -x "$BIN" ] || exit 0
MARKER="${TMPDIR:-/tmp}/sketchybar_open_popup"

read -r OPEN_ITEM BASE < <(cat "$MARKER" 2>/dev/null)
[ -z "$OPEN_ITEM" ] && exit 0

# one cheap verification: marker can go stale if a click_script closed the popup
DRAWING=$(sketchybar --query "$OPEN_ITEM" 2>/dev/null | awk '/"popup"/ {getline l; print (l ~ /"on"/) ? 1 : 0; exit}')
if [ "$DRAWING" != "1" ]; then
  rm -f "$MARKER"
  exit 0
fi

read -r _ Y CLICKS _ _ _ < <("$BIN")

# any click below the bar closes the popup; the volume popup gets a taller
# protected zone so slider drags aren't cut short. Row click_scripts still run
# before the close lands on the next tick.
ZONE=30
[ "$OPEN_ITEM" = "volume" ] && ZONE=150
ZONE="${CLICKWATCH_ZONE:-$ZONE}"

if [ "$CLICKS" -gt "${BASE:-$CLICKS}" ] && [ "$Y" -gt "$ZONE" ]; then
  sketchybar --set "/.*/" popup.drawing=off
  rm -f "$MARKER"
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
