#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover

LOC_CACHE="$CONFIG_DIR/.loc"
[ -f "$LOC_CACHE" ] || curl -s --max-time 5 ipinfo.io/loc > "$LOC_CACHE" 2>/dev/null
LOC=$(cat "$LOC_CACHE" 2>/dev/null)
LAT="${LOC%,*}" LON="${LOC#*,}"
[ -z "$LAT" ] || [ -z "$LON" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

TEMP=$(curl -s --max-time 8 "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m" \
  | python3 -c "import json,sys; print(round(json.load(sys.stdin)['current']['temperature_2m']))" 2>/dev/null)
AQI=$(curl -s --max-time 8 "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$LAT&longitude=$LON&current=european_aqi" \
  | python3 -c "import json,sys; print(round(json.load(sys.stdin)['current']['european_aqi']))" 2>/dev/null)

[ -z "$TEMP" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

COLOR=$CYAN
if [ -n "$AQI" ]; then
  [ "$AQI" -gt 50 ] && COLOR=$ORANGE
  [ "$AQI" -gt 100 ] && COLOR=$RED
  LABEL="${TEMP}° · AQI $AQI"
else
  LABEL="${TEMP}°"
fi
sketchybar --set "$NAME" drawing=on label="$LABEL" icon.color=$COLOR
