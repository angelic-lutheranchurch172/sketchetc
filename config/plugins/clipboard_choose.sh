#!/bin/bash
# Option+V: centered clipboard picker (arrow keys + Enter, click, Esc; image previews)
STORE="$HOME/.local/share/sketchetc/clipboard"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

FILES=()
while read -r f; do FILES+=("$STORE/$f"); done < <(ls -t "$STORE" 2>/dev/null | grep -v '^\.' | head -5)

[ "${#FILES[@]}" -eq 0 ] && { "$CONFIG_DIR/plugins/notify.sh" "Clipboard" "Nothing copied yet"; exit 0; }

PICK=$("$CONFIG_DIR/plugins/bin/clip_picker" "${FILES[@]}") || exit 0
[ -n "$PICK" ] && exec "$CONFIG_DIR/plugins/clipboard_row.sh" paste "$PICK"
