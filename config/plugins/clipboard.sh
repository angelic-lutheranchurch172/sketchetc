#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

STORE="$HOME/.local/share/sketchetc/clipboard"
mkdir -p "$STORE"
LAST_HASH_FILE="$STORE/.last"
MAX=30

capture() {
  local info hash f
  info=$(osascript -e 'clipboard info' 2>/dev/null)
  [ -z "$info" ] && return
  if [[ "$info" == *"PNGf"* || "$info" == *"TIFF"* ]]; then
    command -v pngpaste >/dev/null || return
    f="$STORE/.candidate.png"
    pngpaste "$f" 2>/dev/null || return
    hash=$(md5 -q "$f")
    [ "$hash" = "$(cat "$LAST_HASH_FILE" 2>/dev/null)" ] && { rm -f "$f"; return; }
    mv "$f" "$STORE/$(date +%s)-img.png"
  else
    local text
    text=$(pbpaste 2>/dev/null | head -c 100000)
    [ -z "$text" ] && return
    hash=$(printf '%s' "$text" | md5 -q)
    [ "$hash" = "$(cat "$LAST_HASH_FILE" 2>/dev/null)" ] && return
    printf '%s' "$text" > "$STORE/$(date +%s)-txt.txt"
  fi
  echo "$hash" > "$LAST_HASH_FILE"
  ls -t "$STORE" | grep -v '^\.' | tail -n +$((MAX + 1)) | while read -r old; do rm -f "$STORE/$old"; done
}

build_popup() {
  sketchybar --remove '/clipboard.row\..*/' 2>/dev/null
  sketchybar --add item clipboard.row.head popup.clipboard \
    --set clipboard.row.head icon.drawing=off background.drawing=off \
      label="Clipboard — click to paste" label.color=$PINK label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  ls -t "$STORE" | grep -v '^\.' | head -10 | while read -r f; do
    i=$((i + 1))
    if [[ "$f" == *-img.png ]]; then
      sketchybar --add item "clipboard.row.$i" popup.clipboard \
        --set "clipboard.row.$i" icon=󰋩 icon.color=$CYAN icon.padding_left=10 \
          background.drawing=off background.corner_radius=6 \
          label="image · $(date -r "${f%%-*}" '+%H:%M')" label.font="$ROW_FONT" label.padding_right=12 \
          script="$CONFIG_DIR/plugins/clipboard_row.sh" \
          click_script="$CONFIG_DIR/plugins/clipboard_row.sh paste '$STORE/$f'" \
        --subscribe "clipboard.row.$i" mouse.entered mouse.exited
      sketchybar --set "clipboard.row.$i" label="image · $(date -r "$STORE/$f" '+%H:%M') (hover to preview)" 2>/dev/null
    else
      PREVIEW=$(head -c 300 "$STORE/$f" | tr '\n\t' '  ' | cut -c1-42)
      sketchybar --add item "clipboard.row.$i" popup.clipboard \
        --set "clipboard.row.$i" icon=󰦨 icon.color=$WHITE icon.padding_left=10 \
          background.drawing=off background.corner_radius=6 \
          label="$PREVIEW" label.font="$ROW_FONT" label.padding_right=12 \
          script="$CONFIG_DIR/plugins/clipboard_row.sh" \
          click_script="$CONFIG_DIR/plugins/clipboard_row.sh paste '$STORE/$f'" \
        --subscribe "clipboard.row.$i" mouse.entered mouse.exited
    fi
    # stash file path for hover preview
    echo "$STORE/$f" > "${TMPDIR:-/tmp}/sketchybar_clip_$i"
  done
  # image hover preview surface (hidden until an image row is hovered)
  sketchybar --add item clipboard.row.preview popup.clipboard \
    --set clipboard.row.preview drawing=off icon.drawing=off label.drawing=off \
      background.drawing=on background.color=$TRANSPARENT \
      background.corner_radius=8 background.padding_left=12 background.padding_right=12
}

case "$SENDER" in
  clip_hotkey|mouse.clicked)
    build_popup
    toggle_popup
    exit 0
    ;;
  routine|forced)
    capture
    ;;
esac
exit 0
