#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/ai_agents.row\..*/' 2>/dev/null
  sketchybar --add item ai_agents.row.head popup.ai_agents \
    --set ai_agents.row.head icon.drawing=off background.drawing=off label="Running agents" \
      label.color=$PURPLE label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -axo pid=,etime=,%cpu=,comm= | grep -E '(^|/| )(claude|codex|gemini)$' | while read -r pid etime pcpu comm; do
    i=$((i + 1))
    sketchybar --add item "ai_agents.row.$i" popup.ai_agents \
      --set "ai_agents.row.$i" icon=󰚩 icon.color=$PURPLE icon.padding_left=10 \
        background.drawing=off \
        label="$(printf '%s · up %s · %s%% cpu · pid %s' "$(basename "$comm")" "$etime" "$pcpu" "$pid")" \
        label.font="$ROW_FONT" label.padding_right=12
  done
  toggle_popup
  exit 0
fi

# ponytail: matches process names claude/codex/gemini; extend the regex for other agents
COUNT=$(ps -axo comm= | grep -cE '(^|/)(claude|codex|gemini)$')

if [ "$COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$COUNT"
else
  sketchybar --set "$NAME" drawing=off
fi
