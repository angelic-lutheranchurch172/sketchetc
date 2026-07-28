#!/bin/bash
source "$CONFIG_DIR/plugins/hover.sh"
hover
close_popup_on_exit
source "$CONFIG_DIR/plugins/aura_lib.sh"

PASSIVE_STATE="${TMPDIR:-/tmp}/sketchybar_aura_passive"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/aura.row\..*/' 2>/dev/null
  TODAY=$(aura_today); WEEK=$(aura_since 7); MONTH=$(aura_since 30)
  sketchybar --add item aura.row.head popup.aura \
    --set aura.row.head icon.drawing=off background.drawing=off \
      label="Aura tracker" label.color=$PURPLE label.font="$HEAD_FONT" \
      label.padding_left=12 label.padding_right=12
  i=0
  while IFS='|' read -r label; do
    i=$((i + 1))
    sketchybar --add item "aura.row.$i" popup.aura \
      --set "aura.row.$i" icon.drawing=off background.drawing=off \
        label="$label" label.font="$ROW_FONT" label.padding_left=12 label.padding_right=12
  done <<EOF
today    $TODAY ✨
7 days   $WEEK
30 days  $MONTH
EOF
  # single Export row; the range options expand inline (accordion)
  sketchybar --add item aura.row.export popup.aura \
    --set aura.row.export icon=󰥶 icon.color=$CYAN icon.padding_left=10 \
      background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 \
      label="Export…" label.font="$ROW_FONT" label.padding_right=12 \
      script="$CONFIG_DIR/plugins/popup_row.sh" \
      click_script="$CONFIG_DIR/plugins/aura_accordion.sh" \
    --subscribe aura.row.export mouse.entered mouse.exited
  for range in day week month year; do
    sketchybar --add item "aura.row.png_$range" popup.aura \
      --set "aura.row.png_$range" drawing=off icon=󰧟 icon.color=$CYAN icon.padding_left=22 \
        background.drawing=on background.color=$TRANSPARENT background.corner_radius=6 \
        label="$range" label.font="$ROW_FONT" label.padding_right=12 \
        script="$CONFIG_DIR/plugins/popup_row.sh" \
        click_script="$CONFIG_DIR/plugins/aura_export.sh $range; sketchybar --set aura popup.drawing=off" \
      --subscribe "aura.row.png_$range" mouse.entered mouse.exited
  done
  fi

# passive accrual: every 30 min tick, meaningful typing earns a trickle
read -r _ _ CLICKS _ _ KEYS < <("$CONFIG_DIR/plugins/bin/mouse_info")
read -r PKEYS PCLICKS < <(cat "$PASSIVE_STATE" 2>/dev/null || echo "$KEYS $CLICKS")
echo "$KEYS $CLICKS" > "$PASSIVE_STATE"
DK=$((KEYS - PKEYS))
if [ "$DK" -gt 500 ] && [ "$(aura_today)" -lt 2000 ]; then
  aura_add 5 passive "$DK" $((CLICKS - PCLICKS)) 0 0
fi
sketchybar --set "$NAME" drawing=on label="$(aura_today)"
