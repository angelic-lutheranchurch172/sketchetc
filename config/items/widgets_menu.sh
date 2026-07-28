#!/bin/bash
# 󰨝 → compact widget on/off popover
sketchybar --add item widgets_menu left \
  --set widgets_menu \
    icon=$ICON_WIDGETS \
    icon.color=$PURPLE \
    icon.padding_left=8 icon.padding_right=8 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=left \
    popup.height=22 \
    script="$PLUGIN_DIR/widgets_menu.sh" \
  --subscribe widgets_menu mouse.clicked mouse.entered mouse.exited mouse.entered.global mouse.exited.global

for w in network caffeine ports pomodoro github weather speedtest meeting focus temps media clipboard aura journal; do
  MARK="○" COLOR=0x66ffffff
  widget_on "$w" && MARK="●" && COLOR=$PINK
  sketchybar --add item "widgets_menu.$w" popup.widgets_menu \
    --set "widgets_menu.$w" icon="$MARK" icon.color="$COLOR" icon.padding_left=10 \
      label="$w" label.font="JetBrainsMono Nerd Font:Regular:11.0" label.padding_right=12 \
      background.drawing=off background.corner_radius=5 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="CFG=\$HOME/.config/sketchybar; if grep -q '^$w=on' \$CFG/widgets.conf; then sed -i '' 's/^$w=on/$w=off/' \$CFG/widgets.conf; else sed -i '' 's/^$w=off/$w=on/' \$CFG/widgets.conf; fi; sketchybar --reload" \
    --subscribe "widgets_menu.$w" mouse.entered mouse.exited
done
