#!/bin/bash
# aura_export.sh day|week|month|year · classy shareable PNG into ~/Downloads
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/aura_lib.sh"
RANGE="${1:-week}"

case "$RANGE" in
  day)   DAYS=1;   TITLE="$(date '+%A, %d %B %Y')" ;;
  week)  DAYS=7;   TITLE="week of $(date -v-6d '+%d %b') · $(date '+%d %b %Y')" ;;
  month) DAYS=30;  TITLE="$(date '+%B %Y')" ;;
  year)  DAYS=365; TITLE="$(date '+%Y') in review" ;;
esac

read -r TOTAL BARS < <(python3 - "$DAYS" "$AURA_DIR" <<'EOF'
import csv, glob, sys, datetime
days, root = int(sys.argv[1]), sys.argv[2]
today = datetime.date.today()
per = {}
for f in glob.glob(root + '/*.csv'):
    for row in csv.reader(open(f)):
        try:
            d = datetime.date.fromisoformat(row[0])
            if (today - d).days < days: per[d] = per.get(d, 0) + int(row[1])
        except (ValueError, IndexError): pass
total = sum(per.values())
if days <= 7:      # daily bars
    pts = [(today - datetime.timedelta(days=i)) for i in range(min(days,7)-1, -1, -1)]
    bars = ','.join(f"{d.strftime('%a')}:{per.get(d,0)}" for d in pts)
elif days <= 31:   # daily bars, no labels needed
    pts = [(today - datetime.timedelta(days=i)) for i in range(days-1, -1, -1)]
    bars = ','.join(f"{d.day}:{per.get(d,0)}" for d in pts)
else:              # monthly bars
    per_m = {}
    for d, v in per.items(): per_m[d.strftime('%b')] = per_m.get(d.strftime('%b'), 0) + v
    months = [ (today - datetime.timedelta(days=30*i)).strftime('%b') for i in range(11, -1, -1) ]
    bars = ','.join(f"{m}:{per_m.get(m,0)}" for m in months)
print(total, bars)
EOF
)

OUT="$HOME/Downloads/aura-$RANGE-$(date +%Y%m%d).png"
ACCENT=$(printf '%s' "$PINK" | sed 's/0xff/#/')
BG=$(printf '%s' "$BAR_COLOR" | sed 's/0x..//; s/^/#/')
"$CONFIG_DIR/plugins/bin/aura_card" "$TITLE" "$TOTAL" "$OUT" "$ACCENT" "$BG" "$BARS" \
  && { open -R "$OUT"; osascript -e "display notification \"Saved to Downloads\" with title \"Aura card exported\""; }
