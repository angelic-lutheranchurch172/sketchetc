#!/bin/bash
# shared interactivity helpers · source at top of every plugin.
# also loads the active theme palette ($PINK/$CYAN/...) + iconset for all plugins.
source "$CONFIG_DIR/colors.sh"

POPUP_MARKER="${TMPDIR:-/tmp}/sketchybar_open_popup"

# one-line description per bar item, shown as a hover tooltip
item_hint() {
  case "$1" in
    apple)        echo "system menu" ;;
    theme_picker) echo "themes and icon sets" ;;
    widgets_menu) echo "toggle widgets on or off" ;;
    front_app)    echo "click to switch apps" ;;
    clock)        echo "click opens Calendar" ;;
    ram)          echo "memory · click for top processes" ;;
    cpu)          echo "processor · click for top processes" ;;
    battery)      echo "click for time left and cycles" ;;
    wifi)         echo "click for IP and toggle" ;;
    volume)       echo "click for slider · scroll to nudge" ;;
    network)      echo "click for top talkers" ;;
    github)       echo "PRs waiting on you" ;;
    pomodoro)     echo "click to start 25 min focus" ;;
    caffeine)     echo "click to keep the Mac awake" ;;
    speedtest)    echo "click to run a speed test" ;;
    focus)        echo "click to toggle Do Not Disturb" ;;
    ports)        echo "dev servers · click to manage" ;;
    clipboard)    echo "copy history · also Option+V" ;;
    aura)         echo "your effort score · click to review" ;;
    journal)      echo "daily work log · click to write" ;;
    media)        echo "click to pause · right-click controls" ;;
    meeting)      echo "click to join the meeting" ;;
  esac
}

# glow + themed tooltip on hover (only wire this to items whose click does something)
hover() {
  case "$SENDER" in
    mouse.entered)
      sketchybar --animate tanh 8 --set "$NAME" background.border_color=$PURPLE
      # items with permanent popup rows can't lend their popup as a tooltip
      case "$NAME" in apple|theme_picker|widgets_menu|wifi|volume|media) exit 0 ;; esac
      if [ ! -f "$POPUP_MARKER" ]; then
        HINT=$(item_hint "$NAME")
        if [ -n "$HINT" ]; then
          # stale rows from the last real popup open persist as items; hide
          # them so the tooltip is ONLY the one-line hint (clicks rebuild rows)
          sketchybar --set "/${NAME}\..*/" drawing=off 2>/dev/null
          sketchybar --remove "$NAME.tt" 2>/dev/null
          sketchybar --add item "$NAME.tt" "popup.$NAME" \
            --set "$NAME.tt" drawing=on icon.drawing=off background.drawing=off \
              label="$HINT" label.color=$CYAN \
              label.font="JetBrainsMono Nerd Font:Regular:11.0" \
              label.padding_left=10 label.padding_right=10 \
            --set "$NAME" $POPUP_PROPS popup.drawing=on
        fi
      fi
      exit 0 ;;
    mouse.exited)
      sketchybar --animate tanh 8 --set "$NAME" background.border_color=$TRANSPARENT
      if [ ! -f "$POPUP_MARKER" ]; then
        sketchybar --set "$NAME" popup.drawing=off
        sketchybar --remove "$NAME.tt" 2>/dev/null
      fi
      exit 0 ;;
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
  sketchybar --remove "$NAME.tt" 2>/dev/null   # hover tooltip must not linger in the real popup
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
