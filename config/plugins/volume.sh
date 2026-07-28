#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

get_vol() { osascript -e 'output volume of (get volume settings)'; }

case "$SENDER" in
  mouse.clicked)
    sketchybar --set volume.slider slider.percentage="$(get_vol)"
    toggle_popup
    exit 0
    ;;
  mouse.scrolled)
    VOL=$(( $(get_vol) + SCROLL_DELTA ))
    [ "$VOL" -gt 100 ] && VOL=100
    [ "$VOL" -lt 0 ] && VOL=0
    osascript -e "set volume output volume $VOL"
    exit 0
    ;;
esac

VOL="$INFO"
[ -z "$VOL" ] && VOL=$(get_vol)

case $VOL in
  [7-9][0-9]|100)   ICON=$ICON_VOL_HI ;;
  [3-6][0-9])       ICON=$ICON_VOL_MID ;;
  [1-9]|[1-2][0-9]) ICON=$ICON_VOL_LO ;;
  *)                ICON=$ICON_VOL_MUTE ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOL}%" \
  --set volume.slider slider.percentage="$VOL"
