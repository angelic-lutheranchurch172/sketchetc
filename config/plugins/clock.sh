#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/clock.cal\..*/' 2>/dev/null
  sketchybar --add item clock.cal.head popup.clock \
    --set clock.cal.head icon.drawing=off background.drawing=off \
      label="$(date '+%A, %d %B %Y')" \
      label.color=$PINK label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  python3 -c "
import calendar, datetime
t = datetime.date.today()
print(''.join(d.center(4) for d in ['Su','Mo','Tu','We','Th','Fr','Sa']))
for week in calendar.Calendar(firstweekday=6).monthdayscalendar(t.year, t.month):
    print(''.join(('[%d]' % d if d == t.day else (str(d) if d else '')).center(4) for d in week))
" | while IFS= read -r line; do
    i=$((i + 1))
    COLOR=$WHITE
    case "$line" in *'['*) COLOR=$PINK ;; esac
    sketchybar --add item "clock.cal.$i" popup.clock \
      --set "clock.cal.$i" icon.drawing=off background.drawing=off \
        label="$line" label.color=$COLOR \
        label.font="$ROW_FONT" label.padding_left=12 label.padding_right=12
  done
  toggle_popup
  exit 0
fi

sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
