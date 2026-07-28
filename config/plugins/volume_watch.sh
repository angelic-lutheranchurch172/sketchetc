#!/bin/bash
# Live volume while dragging: sliders only emit an event on drag-release
# (documented), so poll the knob position while the volume popup is open.
LOCK="${TMPDIR:-/tmp}/sketchybar_volwatch.pid"
[ -f "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null && exit 0
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

LAST=-1
END=$((SECONDS + 120))
while [ $SECONDS -lt $END ]; do
  OPEN=$(sketchybar --query volume | awk '/"popup"/ {getline l; print (l ~ /"on"/) ? 1 : 0; exit}')
  [ "$OPEN" != "1" ] && break
  PCT=$(sketchybar --query volume.slider | awk -F'[:,]' '/"percentage"/ {gsub(/[^0-9]/,"",$2); print $2; exit}')
  if [ -n "$PCT" ] && [ "$PCT" != "$LAST" ]; then
    osascript -e "set volume output volume $PCT"
    LAST=$PCT
  fi
  sleep 0.15
done
