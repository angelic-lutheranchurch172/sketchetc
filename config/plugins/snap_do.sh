#!/bin/bash
# snap_do.sh <left|right|top|bottom|l3|m3|r3|max|center>
# Snaps the frontmost app's window via AX (sketchybar holds the grant).
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
BARH=30
read -r _ _ _ H W _ < <("$CONFIG_DIR/plugins/bin/mouse_info")
[ -z "$W" ] && exit 0
AH=$((H - BARH))   # usable height below the bar

case "$1" in
  left)   X=0;            Y=$BARH; WW=$((W / 2)); HH=$AH ;;
  right)  X=$((W / 2));   Y=$BARH; WW=$((W / 2)); HH=$AH ;;
  top)    X=0;            Y=$BARH; WW=$W;         HH=$((AH / 2)) ;;
  bottom) X=0;            Y=$((BARH + AH / 2)); WW=$W; HH=$((AH / 2)) ;;
  l3)     X=0;            Y=$BARH; WW=$((W / 3)); HH=$AH ;;
  m3)     X=$((W / 3));   Y=$BARH; WW=$((W / 3)); HH=$AH ;;
  r3)     X=$((2 * W / 3)); Y=$BARH; WW=$((W / 3)); HH=$AH ;;
  max)    X=0;            Y=$BARH; WW=$W;         HH=$AH ;;
  center) WW=$((W * 3 / 5)); HH=$((AH * 3 / 5)); X=$(((W - WW) / 2)); Y=$((BARH + (AH - HH) / 2)) ;;
  *) exit 0 ;;
esac

osascript <<AS 2>/dev/null
tell application "System Events"
  set p to first application process whose frontmost is true
  tell window 1 of p
    set position to {$X, $Y}
    set size to {$WW, $HH}
  end tell
end tell
AS
