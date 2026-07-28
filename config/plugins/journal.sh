#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit
source "$CONFIG_DIR/plugins/journal_lib.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/journal.row\..*/' 2>/dev/null
  add_jrow() { # name icon label cmd hint [hidden]
    sketchybar --add item "journal.row.$1" popup.journal \
      --set "journal.row.$1" icon="$2" icon.color=$CYAN icon.padding_left=10 \
        background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 \
        label="$3" label.font="$ROW_FONT" label.padding_right=12 \
        ${6:+drawing=off icon.padding_left=22} \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="$CONFIG_DIR/plugins/journal_actions.sh $4; sketchybar --set journal popup.drawing=off" \
      --subscribe "journal.row.$1" mouse.entered mouse.exited
  }
  sketchybar --add item journal.row.head popup.journal \
    --set journal.row.head icon.drawing=off background.drawing=off \
      label="Journal · $([ -f "$(jtoday_file)" ] && echo 'today locked ✓' || echo 'today open')" \
      label.color=$PINK label.font="$HEAD_FONT" label.padding_left=12 label.padding_right=12
  if [ -z "$(jroot)" ]; then
    add_jrow setup 󰒓 "Set up journal…" setup "choose folder, working days, cutoff"
  else
    if [ ! -f "$(jtoday_file)" ]; then
      add_jrow draft 󰷈 "Write today's update" draft "centered editor, append anytime today"
      add_jrow final 󰌾 "Finalize & lock today" finalize "hashes and locks the entry forever"
    fi
    add_jrow view   󰈈 "View entries" view "pick a day, rendered in Quick Look"
    add_jrow browse 󰉋 "Browse folder" browse "opens the journal root in Finder"
    sketchybar --add item journal.row.copyhead popup.journal \
      --set journal.row.copyhead icon=󰆏 icon.color=$CYAN icon.padding_left=10 \
        background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 \
        label="Copy…" label.font="$ROW_FONT" label.padding_right=12 \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="$CONFIG_DIR/plugins/journal_accordion.sh" \
      --subscribe journal.row.copyhead mouse.entered mouse.exited
    for r in day week month year; do
      add_jrow "copy_$r" 󰧟 "$r" "copy $r" "" hidden
    done
    add_jrow verify 󰄬 "Verify audit chain" verify "recomputes every hash in the chain"
  fi
  fi

# routine: state color + cutoff enforcement
if [ -z "$(jroot)" ]; then
  sketchybar --set "$NAME" icon.color=0x66ffffff
  exit 0
fi
if [ -f "$(jtoday_file)" ]; then
  sketchybar --set "$NAME" icon.color=$CYAN
elif jis_workday && jpast_cutoff; then
  jfinalize
  sketchybar --set "$NAME" icon.color=$CYAN
elif jis_workday; then
  sketchybar --set "$NAME" icon.color=$ORANGE
else
  sketchybar --set "$NAME" icon.color=0x66ffffff
fi
