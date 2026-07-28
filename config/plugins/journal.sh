#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit
source "$CONFIG_DIR/plugins/journal_lib.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/journal.row\..*/' 2>/dev/null
  add_jrow() { # name icon label cmd
    sketchybar --add item "journal.row.$1" popup.journal \
      --set "journal.row.$1" icon="$2" icon.color=$CYAN icon.padding_left=10 \
        background.drawing=off background.corner_radius=6 \
        label="$3" label.font="$ROW_FONT" label.padding_right=12 \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="$CONFIG_DIR/plugins/journal_actions.sh $4; sketchybar --set journal popup.drawing=off" \
      --subscribe "journal.row.$1" mouse.entered mouse.exited
  }
  sketchybar --add item journal.row.head popup.journal \
    --set journal.row.head icon.drawing=off background.drawing=off \
      label="Journal — $([ -f "$(jtoday_file)" ] && echo 'today is locked ✓' || echo 'today: not written')" \
      label.color=$PINK label.font="$HEAD_FONT" label.padding_left=12 label.padding_right=12
  if [ -z "$(jroot)" ]; then
    add_jrow setup 󰒓 "Set up journal…" setup
  else
    [ -f "$(jtoday_file)" ] || {
      add_jrow draft 󰷈 "Write today's update" draft
      add_jrow final 󰌾 "Finalize & lock today" finalize
    }
    add_jrow cday   󰆏 "Copy day" "copy day"
    add_jrow cweek  󰆏 "Copy week" "copy week"
    add_jrow cmonth 󰆏 "Copy month" "copy month"
    add_jrow cyear  󰆏 "Copy year" "copy year"
    add_jrow verify 󰄬 "Verify audit chain" verify
  fi
  toggle_popup
  exit 0
fi

# routine: state color + cutoff enforcement
if [ -z "$(jroot)" ]; then
  sketchybar --set "$NAME" icon.color=0x66ffffff
  exit 0
fi
if [ -f "$(jtoday_file)" ]; then
  sketchybar --set "$NAME" icon.color=$CYAN
elif jis_workday && jpast_cutoff; then
  jfinalize    # auto-lock at cutoff (draft or "(no update logged)" stub)
  sketchybar --set "$NAME" icon.color=$CYAN
elif jis_workday; then
  sketchybar --set "$NAME" icon.color=$ORANGE   # nudge: not written yet
else
  sketchybar --set "$NAME" icon.color=0x66ffffff
fi
