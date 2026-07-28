#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"

command -v macmon >/dev/null || { sketchybar --set "$NAME" drawing=off; exit 0; }

# one macmon sample: cpu temp from temp.cpu_temp_avg, fan speed from fans[].rpm
# (fanless Macs report no fans / rpm 0 · the rpm segment auto-hides)
read -r TEMP RPM < <(macmon pipe -s 1 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print('', ''); raise SystemExit
t = (d.get('temp') or {}).get('cpu_temp_avg')
rpm = max((f.get('rpm', 0) for f in d.get('fans') or []), default=0)
print(round(t) if t else '', round(rpm))
")

[ -z "$TEMP" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

COLOR=$CYAN
[ "$TEMP" -gt 75 ] && COLOR=$ORANGE
[ "$TEMP" -gt 90 ] && COLOR=$RED

LABEL="${TEMP}°"
[ "$RPM" -gt 0 ] && LABEL="${TEMP}° · ${RPM}rpm"

sketchybar --set "$NAME" drawing=on label="$LABEL" icon.color=$COLOR
