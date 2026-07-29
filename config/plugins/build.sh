#!/bin/bash
# build.sh — compile any helper whose binary is missing or older than its source.
# The binaries are gitignored (Scorecard flags committed Mach-O), so a fresh
# clone has zero of them. Every entry point routes here instead of keeping its
# own list, because a hardcoded list silently rots when a new helper lands.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
BIN="$CONFIG_DIR/plugins/bin"
command -v swiftc >/dev/null || exit 0

built=0
for s in "$BIN"/*.swift; do
  [ -e "$s" ] || continue
  out="${s%.swift}"
  [ -x "$out" ] && [ "$out" -nt "$s" ] && continue
  if swiftc -O -o "$out" "$s" 2>/dev/null; then
    built=$((built + 1))
    # a rebuilt long-lived helper must be respawned, or the old image keeps running
    case "$(basename "$out")" in
      clip_watch) pkill -f "$out" 2>/dev/null ;;
    esac
  else
    echo "build.sh: failed to compile $(basename "$s")" >&2
  fi
done
[ "$built" -gt 0 ] && echo "built $built helper(s)"
exit 0
