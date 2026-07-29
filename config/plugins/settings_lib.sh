#!/bin/bash
# shared settings accessor
SETTINGS_FILE="${CONFIG_DIR:-$HOME/.config/sketchybar}/settings.conf"
setting() { awk -F= -v k="$1" '$1 == k {print $2; exit}' "$SETTINGS_FILE" 2>/dev/null; }
setting_on() { [ "$(setting "$1")" != "off" ]; }   # default-on semantics
