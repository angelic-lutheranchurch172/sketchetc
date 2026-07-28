#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/ai_agents.row\..*/' 2>/dev/null
  sketchybar --add item ai_agents.row.head popup.ai_agents \
    --set ai_agents.row.head icon.drawing=off background.drawing=off label="Running agents" \
      label.color=0xff9b5de5 label.font="JetBrainsMono Nerd Font:Bold:13.0" \
      label.padding_left=12 label.padding_right=12
  i=0
  ps -axo pid=,%cpu=,comm= | grep -E '(^|/)(claude|codex|gemini)$' | while read -r pid pcpu comm; do
    i=$((i + 1))
    sketchybar --add item "ai_agents.row.$i" popup.ai_agents \
      --set "ai_agents.row.$i" icon=󰚩 icon.color=0xff9b5de5 icon.padding_left=10 \
        background.drawing=off \
        label="$(printf '%s · pid %s · %s%% cpu' "$(basename "$comm")" "$pid" "$pcpu")" \
        label.font="JetBrainsMono Nerd Font:Regular:12.0" label.padding_right=12
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
