#!/bin/bash
# 󰏘 → one-row popover: theme color dots + iconset switcher. Zero text noise.
sketchybar --add item theme_picker left \
  --set theme_picker \
    icon=$ICON_THEME \
    icon.color=$CYAN \
    icon.padding_left=8 icon.padding_right=8 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=left \
    popup.horizontal=on \
    popup.height=34 \
    script="$PLUGIN_DIR/theme_picker.sh" \
  --subscribe theme_picker mouse.clicked mouse.entered mouse.exited mouse.entered.global mouse.exited.global

CURRENT_THEME=$(cat "$CONFIG_DIR/.theme" 2>/dev/null || echo vice-city)
# theme accents mirrored here so every dot shows its own color regardless of active theme
for entry in "vice-city:0xffff6ec7" "cyberpunk:0xfffcee0a" "matrix:0xff00ff41" "catppuccin:0xffcba6f7" "miami-sunset:0xffff5e78"; do
  t="${entry%%:*}" c="${entry##*:}"
  DOT=󰝦; [ "$t" = "$CURRENT_THEME" ] && DOT=󰝥
  sketchybar --add item "theme_picker.$t" popup.theme_picker \
    --set "theme_picker.$t" icon="$DOT" icon.color="$c" \
      icon.font="JetBrainsMono Nerd Font:Bold:20.0" \
      icon.padding_left=6 icon.padding_right=6 label.drawing=off background.drawing=off \
      click_script="echo $t > \$HOME/.config/sketchybar/.theme; \$HOME/.config/sketchybar/plugins/notify.sh sketchetc 'Theme: $t'; sketchybar --reload"
done

CURRENT_SET=$(cat "$CONFIG_DIR/.iconset" 2>/dev/null || echo nerd)
for s in nerd minimal emoji; do
  COLOR=0x66ffffff; [ "$s" = "$CURRENT_SET" ] && COLOR=$PINK
  sketchybar --add item "theme_picker.set_$s" popup.theme_picker \
    --set "theme_picker.set_$s" icon.drawing=off label="$s" label.color="$COLOR" \
      label.font="JetBrainsMono Nerd Font:Bold:11.0" \
      label.padding_left=8 label.padding_right=8 background.drawing=off \
      click_script="echo $s > \$HOME/.config/sketchybar/.iconset; \$HOME/.config/sketchybar/plugins/notify.sh sketchetc 'Icons: $s'; sketchybar --reload"
done
