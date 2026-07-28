#!/bin/bash
# aura accounting · source after hover.sh. CSV: date,points,kind,keys,clicks,agents,prs
AURA_DIR="$HOME/.local/share/sketchetc/aura"
mkdir -p "$AURA_DIR"

aura_csv() { echo "$AURA_DIR/$(date +%Y-%m).csv"; }

aura_today() {
  awk -F, -v d="$(date +%Y-%m-%d)" '$1 == d {s += $2} END {print s + 0}' "$(aura_csv)" 2>/dev/null
}

aura_since() { # days-back -> total
  python3 - "$1" "$AURA_DIR" <<'EOF'
import csv, glob, sys, datetime
days, root = int(sys.argv[1]), sys.argv[2]
cutoff = datetime.date.today() - datetime.timedelta(days=days)
total = 0
for f in glob.glob(root + '/*.csv'):
    for row in csv.reader(open(f)):
        try:
            if datetime.date.fromisoformat(row[0]) >= cutoff: total += int(row[1])
        except (ValueError, IndexError): pass
print(total)
EOF
}

aura_add() { # points kind keys clicks agents prs
  echo "$(date +%Y-%m-%d),$1,$2,${3:-0},${4:-0},${5:-0},${6:-0}" >> "$(aura_csv)"
}

aura_award() { # points  · celebrate: flash widget + voice + notification
  local P=$1
  aura_add "$P" "${2:-pomodoro}" "${3:-0}" "${4:-0}" "${5:-0}" "${6:-0}"
  "$CONFIG_DIR/plugins/notify.sh" "Aura" "+$P aura · locked in 🔥" &
  say -v Samantha "Plus $P aura points. You are locked in." &
  sketchybar --set aura drawing=on label="+$P ✨" label.color=$PINK icon.color=$PINK
  sketchybar --animate sin 20 --set aura icon.y_offset=4 icon.y_offset=0
  sleep 4
  sketchybar --animate tanh 30 --set aura label.color=$WHITE icon.color=$PURPLE
  sketchybar --set aura label="$(aura_today)"
}
