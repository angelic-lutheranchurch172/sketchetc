#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  TIME_LEFT=$(pmset -g batt | grep -Eo '[0-9]+:[0-9]+ remaining' | head -1)
  [ -z "$TIME_LEFT" ] && TIME_LEFT="calculating…"
  CYCLES=$(ioreg -r -c AppleSmartBattery | awk '/"CycleCount" =/ {print $3}')
  sketchybar --remove '/battery.info\..*/' 2>/dev/null
  sketchybar \
    --add item battery.info.time popup.battery \
    --set battery.info.time icon=󰥔 icon.color=0xffffa552 icon.padding_left=10 \
      label="$TIME_LEFT" label.padding_right=12 \
    --add item battery.info.cycles popup.battery \
    --set battery.info.cycles icon=󰑓 icon.color=0xffffa552 icon.padding_left=10 \
      label="${CYCLES:-?} cycles" label.padding_right=12
  toggle_popup
  exit 0
fi

BATT=$(pmset -g batt)
PCT=$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
[ -z "$PCT" ] && exit 0

if echo "$BATT" | grep -q 'AC Power'; then
  ICON=󰂄 COLOR=0xff0bd3d3
else
  case $PCT in
    9[0-9]|100) ICON=󰁹 ;;
    [6-8][0-9]) ICON=󰂀 ;;
    [3-5][0-9]) ICON=󰁾 ;;
    [1-2][0-9]) ICON=󰁻 ;;
    *)          ICON=󰁺 ;;
  esac
  COLOR=0xffffa552
  [ "$PCT" -le 20 ] && COLOR=0xffff5577
fi

sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${PCT}%"
