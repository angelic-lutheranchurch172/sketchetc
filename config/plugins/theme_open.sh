#!/bin/bash
# Opens the Theme Studio (detached-safe: call via the nohup pattern)
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
exec "$CONFIG_DIR/plugins/bin/theme_win" \
  "$CONFIG_DIR/themes" \
  "$(cat "$CONFIG_DIR/.theme" 2>/dev/null || echo vice-city)" \
  "$(cat "$CONFIG_DIR/.iconset" 2>/dev/null || echo nerd)" \
  "$BAR_COLOR" "$ITEM_BG_COLOR" "$PINK" "$CYAN"
