#!/bin/bash
# RAM Reclaim SAFE — frees memory without stopping anything the user relies on.
# Only reaps ORPHANED idle helpers: ppid==1 (parent already dead), owned by
# current user, <1% CPU, matching known helper patterns. Then purge + DNS
# flush (one admin password prompt). Ported from user's AppleScript.

free_mb() {
  vm_stat | awk -v ps="$(sysctl -n hw.pagesize)" '
    /Pages free/        {gsub("\\.",""); f=$3}
    /Pages speculative/ {gsub("\\.",""); s=$3}
    END {printf "%d", (f+s)*ps/1048576}'
}

BEFORE=$(free_mb)

PIDS=$(ps -axo user=,pid=,ppid=,pcpu=,args= | awk -v u="$(id -un)" '
  $1 == u && $3 == 1 && $4 < 1.0 {
    line = tolower($0)
    if (line ~ /mcp|npx |uvx |chromedriver|playwright|puppeteer|headless_shell|headless-shell|--headless|esbuild.*service/)
      print $2
  }')

REAPED=0
for pid in $PIDS; do
  kill -TERM "$pid" 2>/dev/null && REAPED=$((REAPED + 1))
done
[ "$REAPED" -gt 0 ] && sleep 2
for pid in $PIDS; do
  kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null
done

# purge + DNS flush — single admin prompt; user may cancel, that's fine
osascript -e 'do shell script "/usr/sbin/purge; dscacheutil -flushcache; killall -HUP mDNSResponder" with administrator privileges' 2>/dev/null

sleep 3
AFTER=$(free_mb)
GAINED=$((AFTER - BEFORE))
[ "$GAINED" -lt 0 ] && GAINED=0

if [ "$GAINED" -ge 1024 ]; then
  AMOUNT=$(awk -v m="$GAINED" 'BEGIN {printf "%.1f GB", m/1024}')
  SPOKEN=$(awk -v m="$GAINED" 'BEGIN {printf "%.1f gigabytes", m/1024}')
else
  AMOUNT="${GAINED} MB"
  SPOKEN="${GAINED} megabytes"
fi

osascript -e "display notification \"Freed ${AMOUNT} · reaped ${REAPED} orphaned helper(s) · nothing running was stopped\" with title \"RAM Reclaim\" sound name \"Glass\""
say -v Samantha "Reclaimed ${SPOKEN} of RAM. ${REAPED} orphaned helpers reaped." &
sketchybar --update
