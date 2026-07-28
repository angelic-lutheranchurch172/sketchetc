#!/bin/bash
# shared interactivity helpers · source at top of every plugin.
# also loads the active theme palette ($PINK/$CYAN/...) + iconset for all plugins.
source "$CONFIG_DIR/colors.sh"

POPUP_MARKER="${TMPDIR:-/tmp}/sketchybar_open_popup"

# glow on hover (only wire this to items whose click does something)
hover() {
  case "$SENDER" in
    mouse.entered) sketchybar --animate tanh 8 --set "$NAME" background.border_color=$PURPLE; exit 0 ;;
    mouse.exited)  sketchybar --animate tanh 8 --set "$NAME" background.border_color=$TRANSPARENT; exit 0 ;;
  esac
}

# macOS-native popup behavior: popups close ONLY on outside click / other item /
# app switch · never on mere mouse-out. These senders are swallowed here.
close_popup_on_exit() {
  case "$SENDER" in
    mouse.exited.global|mouse.entered.global) exit 0 ;;
  esac
}

# exclusive toggle: close every other popup, then toggle self. The marker file
# records "<name> <click-counter-at-open>" so click_watch closes only on clicks
# that happen AFTER the popup opened (the opening click can never self-close).
toggle_popup() {
  WAS_OPEN=0
  [ "$(cat "$POPUP_MARKER" 2>/dev/null | awk '{print $1}')" = "$NAME" ] && WAS_OPEN=1
  sketchybar --set "/.*/" popup.drawing=off
  rm -f "$POPUP_MARKER"
  if [ "$WAS_OPEN" -eq 0 ]; then
    sketchybar --animate sin 12 --set "$NAME" icon.y_offset=3 icon.y_offset=0
    sketchybar --set "$NAME" popup.drawing=on
    read -r _ _ OPEN_CLICKS _ _ _ < <("$CONFIG_DIR/plugins/bin/mouse_info" 2>/dev/null || echo "0 0 0 0 0 0")
    echo "$NAME ${OPEN_CLICKS:-0}" > "$POPUP_MARKER"
  fi
}

close_all_popups() {
  sketchybar --set "/.*/" popup.drawing=off
  rm -f "$POPUP_MARKER"
}

# human-readable size from a KB value: 823K · 12.4M · 1.2G · 1.1T
human_kb() {
  awk -v k="$1" 'BEGIN {
    if (k >= 1073741824)      printf "%.1fT", k/1073741824
    else if (k >= 1048576)    printf "%.1fG", k/1048576
    else if (k >= 1024)       printf "%.1fM", k/1024
    else                      printf "%dK", k
  }'
}

# standard styling for dynamic popup rows
ROW_FONT="JetBrainsMono Nerd Font:Regular:12.0"
HEAD_FONT="JetBrainsMono Nerd Font:Bold:13.0"
