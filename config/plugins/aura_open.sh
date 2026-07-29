#!/bin/bash
# Opens the Aura window (launch detached from click_scripts)
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/storage_lib.sh"
data_ensure
exec "$CONFIG_DIR/plugins/bin/aura_win" "$(aura_dir)" \
  "$BAR_COLOR" "$ITEM_BG_COLOR" "$PINK" "$CYAN"
