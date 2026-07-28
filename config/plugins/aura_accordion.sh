#!/bin/bash
# expand/collapse the aura export range rows inline
STATE=$(sketchybar --query aura.row.png_day 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['geometry']['drawing'])" 2>/dev/null)
if [ "$STATE" = "on" ]; then V=off; else V=on; fi
for r in day week month year; do sketchybar --set "aura.row.png_$r" drawing=$V; done
