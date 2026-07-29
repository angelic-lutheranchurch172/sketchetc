#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

STORE="$HOME/.local/share/sketchetc/clipboard"
mkdir -p "$STORE"
MAX=5   # keep it tight: only the last five copies

# if content matches an EXISTING entry, bump it to the top (newest); otherwise
# store as a new entry. Catches every copy source: ⌘C, menu copy, web copies.
bump_or_store() { # hash tmpfile suffix
  local hash="$1" tmp="$2" suffix="$3" f
  for f in "$STORE"/*."${suffix##*.}"; do
    [ -f "$f" ] || continue
    if [ "$(md5 -q "$f")" = "$hash" ]; then
      touch "$f"                       # re-copy of an old entry: newest again
      rm -f "$tmp"
      return
    fi
  done
  mv "$tmp" "$STORE/$(date +%s)-$suffix"
  ls -t "$STORE" | grep -v '^\.' | tail -n +$((MAX + 1)) | while read -r old; do rm -f "$STORE/$old"; done
}

capture() {
  local info hash f
  info=$(osascript -e 'clipboard info' 2>/dev/null)
  [ -z "$info" ] && return
  if [[ "$info" == *"PNGf"* || "$info" == *"TIFF"* ]]; then
    command -v pngpaste >/dev/null || return
    f="$STORE/.candidate.png"
    pngpaste "$f" 2>/dev/null || return
    hash=$(md5 -q "$f")
    bump_or_store "$hash" "$f" "img.png"
  else
    local text
    text=$(pbpaste 2>/dev/null | head -c 100000)
    [ -z "$text" ] && return
    hash=$(printf '%s' "$text" | md5 -q)
    f="$STORE/.candidate.txt"
    printf '%s' "$text" > "$f"
    bump_or_store "$hash" "$f" "txt.txt"
  fi
}

build_popup() {
  sketchybar --remove '/clipboard.row\..*/' 2>/dev/null
  sketchybar --add item clipboard.row.head popup.clipboard \
    --set clipboard.row.head icon.drawing=off background.drawing=off \
      label="Clipboard · click to paste" label.color=$PINK label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  ls -t "$STORE" | grep -v '^\.' | head -5 | while read -r f; do
    i=$((i + 1))
    if [[ "$f" == *-img.png ]]; then
      # small always-visible thumbnail on the left (scale computed per image)
      IMG_H=$(sips -g pixelHeight "$STORE/$f" 2>/dev/null | awk '/pixelHeight/ {print $2}')
      SCALE=$(awk -v h="${IMG_H:-800}" 'BEGIN {printf "%.4f", 36 / h}')
      sketchybar --add item "clipboard.row.$i" popup.clipboard \
        --set "clipboard.row.$i" icon=" " icon.width=72 icon.padding_left=10 icon.padding_right=6 \
          icon.background.drawing=on \
          icon.background.height=36 \
          icon.background.color=$TRANSPARENT \
          icon.background.image="$STORE/$f" \
          icon.background.image.scale="$SCALE" \
          icon.background.image.corner_radius=4 \
          background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 width=340 \
          label="image · $(date -r "$STORE/$f" '+%H:%M')" label.font="$ROW_FONT" label.padding_right=12 \
          script="$CONFIG_DIR/plugins/popup_row.sh" \
          click_script="$CONFIG_DIR/plugins/clipboard_row.sh paste '$STORE/$f'" \
        --subscribe "clipboard.row.$i" mouse.entered mouse.exited
    else
      PREVIEW=$(head -c 300 "$STORE/$f" | tr '\n\t' '  ' | cut -c1-42)
      sketchybar --add item "clipboard.row.$i" popup.clipboard \
        --set "clipboard.row.$i" icon=󰦨 icon.color=$WHITE icon.padding_left=10 \
          background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 width=340 \
          label="$PREVIEW" label.font="$ROW_FONT" label.padding_right=12 \
          script="$CONFIG_DIR/plugins/popup_row.sh" \
          click_script="$CONFIG_DIR/plugins/clipboard_row.sh paste '$STORE/$f'" \
        --subscribe "clipboard.row.$i" mouse.entered mouse.exited
    fi
  done
}

case "$SENDER" in
  clip_hotkey|mouse.clicked)
    capture
    build_popup
    toggle_popup
    exit 0
    ;;
  clip_captured)
    capture
    exit 0
    ;;
  routine|forced)
    capture
    ;;
esac
exit 0
