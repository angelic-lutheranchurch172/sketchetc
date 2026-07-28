#!/bin/bash
# Option+V: native macOS list of clipboard history (arrow keys + Enter, or mouse)
STORE="$HOME/.local/share/sketchetc/clipboard"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

ITEMS=()
FILES=()
i=0
while read -r f; do
  i=$((i + 1))
  if [[ "$f" == *-img.png ]]; then
    label="$i · image · $(date -r "$STORE/$f" '+%H:%M')"
  else
    label="$i · $(head -c 200 "$STORE/$f" | tr '\n\t"\\' '    ' | cut -c1-60)"
  fi
  ITEMS+=("\"$label\"")
  FILES+=("$STORE/$f")
done < <(ls -t "$STORE" 2>/dev/null | grep -v '^\.' | head -15)

[ "$i" -eq 0 ] && { osascript -e 'display notification "Nothing copied yet" with title "Clipboard"'; exit 0; }

LIST=$(IFS=,; echo "${ITEMS[*]}")
PICK=$(osascript -e "choose from list {$LIST} with prompt \"Clipboard history\" with title \"sketchetc\"" 2>/dev/null)
[ "$PICK" = "false" ] || [ -z "$PICK" ] && exit 0

IDX="${PICK%% ·*}"
exec "$CONFIG_DIR/plugins/clipboard_row.sh" paste "${FILES[$((IDX - 1))]}"
