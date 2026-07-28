#!/bin/bash
# journal core — tamper-evident daily work log
# conf: root=<dir> days=Mon,Tue,... cutoff=HH:MM
JCONF="$HOME/.local/share/sketchetc/journal.conf"
JDRAFT="$HOME/.local/share/sketchetc/journal_draft.md"

jconf() { awk -F= -v k="$1" '$1 == k {print $2}' "$JCONF" 2>/dev/null; }
jroot() { jconf root; }

jtoday_file() { echo "$(jroot)/$(date +%Y)/$(date +%m)/$(date +%d).md"; }

jis_workday() {
  local days; days=$(jconf days)
  [ -z "$days" ] && days="Mon,Tue,Wed,Thu,Fri"
  [[ ",$days," == *",$(date +%a),"* ]]
}

jpast_cutoff() {
  local cutoff; cutoff=$(jconf cutoff); [ -z "$cutoff" ] && cutoff="21:00"
  [ "$(date +%H:%M)" \> "$cutoff" ] || [ "$(date +%H:%M)" = "$cutoff" ]
}

jindex() { echo "$(jroot)/index.log"; }

jchain_append() { # file
  local idx prev hash line
  idx=$(jindex)
  prev=$(tail -1 "$idx" 2>/dev/null | shasum -a 256 | awk '{print $1}')
  [ -s "$idx" ] || prev="genesis"
  hash=$(shasum -a 256 "$1" | awk '{print $1}')
  line="$prev $(date +%Y-%m-%d) ${1#"$(jroot)"/} $hash"
  echo "$line" >> "$idx"
}

jfinalize() { # [content-file]  — write today's entry, chain it, lock it
  local f dir src
  f=$(jtoday_file); dir=$(dirname "$f")
  [ -z "$(jroot)" ] && return 1
  [ -f "$f" ] && return 0   # already finalized today
  mkdir -p "$dir"
  src="${1:-$JDRAFT}"
  {
    echo "# $(date '+%A, %d %B %Y')"
    echo
    echo "> aura today: $(source "$CONFIG_DIR/plugins/aura_lib.sh"; aura_today) · finalized $(date '+%H:%M')"
    echo
    if [ -s "$src" ]; then cat "$src"; else echo "_(no update logged)_"; fi
  } > "$f"
  jchain_append "$f"
  chflags uchg "$f"          # macOS immutable flag — editors and rm bounce off
  rm -f "$JDRAFT"
  osascript -e 'display notification "Today'"'"'s update is locked in" with title "Journal" sound name "Glass"' &
}

jverify() { # -> OK or TAMPERED <file>
  local idx prev expected
  idx=$(jindex); prev="genesis"
  [ -s "$idx" ] || { echo "OK (empty)"; return; }
  while read -r p d rel hash; do
    if [ "$p" != "$prev" ]; then echo "TAMPERED chain@$d"; return; fi
    if [ "$(shasum -a 256 "$(jroot)/$rel" 2>/dev/null | awk '{print $1}')" != "$hash" ]; then
      echo "TAMPERED $rel"; return
    fi
    prev=$(echo "$p $d $rel $hash" | shasum -a 256 | awk '{print $1}')
  done < "$idx"
  echo "OK ($(wc -l < "$idx" | tr -d ' ') entries)"
}

jexport() { # day|week|month|year -> markdown to stdout
  local days
  case "$1" in day) days=1 ;; week) days=7 ;; month) days=31 ;; year) days=366 ;; esac
  python3 - "$days" "$(jroot)" <<'EOF'
import datetime, pathlib, sys
days, root = int(sys.argv[1]), pathlib.Path(sys.argv[2])
today = datetime.date.today()
out, cur_y, cur_m = [], None, None
for i in range(days - 1, -1, -1):
    d = today - datetime.timedelta(days=i)
    f = root / f"{d.year}" / f"{d.month:02d}" / f"{d.day:02d}.md"
    if not f.exists(): continue
    if d.year != cur_y: out.append(f"# {d.year}"); cur_y, cur_m = d.year, None
    if d.month != cur_m: out.append(f"## {d.strftime('%B')}"); cur_m = d.month
    body = f.read_text()
    body = body.split('\n', 1)[1] if body.startswith('#') else body
    out.append(f"### {d.strftime('%a %d %b')}\n{body.strip()}\n")
print('\n'.join(out) if out else '_(no entries in range)_')
EOF
}
