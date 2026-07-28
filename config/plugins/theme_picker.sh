#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit
[ "$SENDER" = "mouse.clicked" ] && toggle_popup
