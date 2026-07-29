#!/bin/bash
# Opens the global Settings window (launch detached from click_scripts)
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
exec "$CONFIG_DIR/plugins/bin/settings_win" \
  "$CONFIG_DIR/settings.conf" "$BAR_COLOR" "$ITEM_BG_COLOR" "$PINK" "$CYAN"
