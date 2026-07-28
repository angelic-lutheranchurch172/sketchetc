#!/bin/bash
export TRANSPARENT=0x00000000

# active theme (hot-swappable via the apple menu)
THEME=$(cat "$CONFIG_DIR/.theme" 2>/dev/null || echo vice-city)
[ -f "$CONFIG_DIR/themes/$THEME.sh" ] || THEME=vice-city
source "$CONFIG_DIR/themes/$THEME.sh"

# shared popup styling (word-split on purpose, values contain no spaces)
export POPUP_PROPS="popup.background.color=$POPUP_BG \
popup.background.border_color=$POPUP_BORDER \
popup.background.border_width=1 \
popup.background.corner_radius=12 \
popup.blur_radius=30 \
popup.background.shadow.drawing=on \
popup.height=26"

# active iconset (nerd | minimal | emoji)
ICONSET=$(cat "$CONFIG_DIR/.iconset" 2>/dev/null || echo nerd)
[ -f "$CONFIG_DIR/icons/$ICONSET.sh" ] || ICONSET=nerd
source "$CONFIG_DIR/icons/$ICONSET.sh"

# widget toggle helper — keys live in widgets.conf
widget_on() { grep -q "^$1=on" "$CONFIG_DIR/widgets.conf" 2>/dev/null; }
