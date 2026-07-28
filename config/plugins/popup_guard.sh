#!/bin/bash
# popup_guard.sh <item> — closes all popups when the user clicks outside the
# bar/popup zone. sketchybar has no mouse.clicked.global event and
# mouse.exited.global is unreliable, so poll the global click counter + cursor
# position (read-only, no permissions needed) via the compiled mouse_info helper.
ITEM="$1"
BIN="$CONFIG_DIR/plugins/bin/mouse_info"
{ [ -n "$ITEM" ] && [ -x "$BIN" ]; } || exit 0

LOCK="${TMPDIR:-/tmp}/sketchybar_popupguard.pid"
[ -f "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null && kill "$(cat "$LOCK")" 2>/dev/null
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

ZONE=380   # px from screen top considered "bar + popup territory"

read -r _ _ LAST _ < <("$BIN")
END=$((SECONDS + 300))
while [ $SECONDS -lt $END ]; do
  OPEN=$(sketchybar --query "$ITEM" 2>/dev/null | awk '/"popup"/ {getline l; print (l ~ /"on"/) ? 1 : 0; exit}')
  [ "$OPEN" != "1" ] && exit 0

  read -r _ Y CLICKS _ < <("$BIN")
  if [ "$CLICKS" -gt "$LAST" ] && [ "$Y" -gt "$ZONE" ]; then
    sketchybar --set "/.*/" popup.drawing=off
    exit 0
  fi
  LAST=$CLICKS
  sleep 0.12
done
