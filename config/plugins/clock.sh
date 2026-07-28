#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
