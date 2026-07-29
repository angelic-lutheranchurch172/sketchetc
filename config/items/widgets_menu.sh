#!/bin/bash
# 󰨝 → compact widget on/off popover with an active-count cap and a help row
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

WIDGETS="spaces network caffeine ports pomodoro github weather speedtest meeting focus temps media clipboard aura journal snap switches shot bluetooth"
for w in $WIDGETS; do
  MARK="○" COLOR=0x66ffffff
  widget_on "$w" && MARK="●" && COLOR=$PINK
  sketchybar --add item "widgets_menu.$w" popup.widgets_menu \
    --set "widgets_menu.$w" icon="$MARK" icon.color="$COLOR" icon.padding_left=10 \
      label="$w" label.font="JetBrainsMono Nerd Font:Regular:11.0" label.padding_right=12 \
      background.drawing=on background.color=$TRANSPARENT background.corner_radius=5 width=240 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="$CONFIG_DIR/plugins/widget_toggle.sh $w" \
    --subscribe "widgets_menu.$w" mouse.entered mouse.exited
done

# help: what does everything do
sketchybar --add item widgets_menu.help popup.widgets_menu \
  --set widgets_menu.help icon="?" icon.color=$CYAN icon.padding_left=12 \
    label="what does everything do" label.font="JetBrainsMono Nerd Font:Regular:11.0" \
    label.padding_right=12 \
    background.drawing=on background.color=$TRANSPARENT background.corner_radius=5 width=240 \
    script="$CONFIG_DIR/plugins/popup_row.sh" \
    click_script="sketchybar --set widgets_menu popup.drawing=off; osascript -e 'do shell script \"nohup $CONFIG_DIR/plugins/help_open.sh > /dev/null 2>&1 &\"'" \
  --subscribe widgets_menu.help mouse.entered mouse.exited
