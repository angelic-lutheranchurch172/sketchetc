#!/bin/bash
# 󰨝 → compact widget on/off popover with hover tooltips and an active-count cap
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

widget_hint() {
  case "$1" in
    spaces)    echo "desktop spaces 1-4, click to switch" ;;
    network)   echo "live up/down speed, click for top talkers" ;;
    caffeine)  echo "keep the Mac awake, click to toggle" ;;
    ports)     echo "running dev servers, click a row to kill" ;;
    pomodoro)  echo "25 min focus timer, earns aura points" ;;
    github)    echo "PRs waiting on you, click to open" ;;
    weather)   echo "temperature and air quality" ;;
    speedtest) echo "one-click internet speed test" ;;
    meeting)   echo "next meeting countdown, click to join" ;;
    focus)     echo "toggle Do Not Disturb" ;;
    temps)     echo "CPU temperature and fan speed" ;;
    media)     echo "now playing, click to pause" ;;
    clipboard) echo "copy history, also on Option+V" ;;
    aura)      echo "your effort score, click to review" ;;
    journal)   echo "tamper-proof daily work log" ;;
  esac
}

WIDGETS="spaces network caffeine ports pomodoro github weather speedtest meeting focus temps media clipboard aura journal"
for w in $WIDGETS; do
  MARK="○" COLOR=0x66ffffff
  widget_on "$w" && MARK="●" && COLOR=$PINK
  sketchybar --add item "widgets_menu.$w" popup.widgets_menu \
    --set "widgets_menu.$w" icon="$MARK" icon.color="$COLOR" icon.padding_left=10 \
      label="$w" label.font="JetBrainsMono Nerd Font:Regular:11.0" label.padding_right=12 \
      background.drawing=on background.color=$TRANSPARENT background.corner_radius=5 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="$CONFIG_DIR/plugins/widget_toggle.sh $w" \
    --subscribe "widgets_menu.$w" mouse.entered mouse.exited
  widget_hint "$w" > "${TMPDIR:-/tmp}/sketchybar_hint_widgets_menu.$w"
done

# tooltip line (always drawn; popup_row.sh swaps its text on hover)
sketchybar --add item widgets_menu.hint popup.widgets_menu \
  --set widgets_menu.hint width=300 icon.drawing=off background.drawing=off \
    label="" label.color=0x44ffffff \
    label.font="JetBrainsMono Nerd Font:Regular:10.0" \
    label.padding_left=12 label.padding_right=12
