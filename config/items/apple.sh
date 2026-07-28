#!/bin/bash
sketchybar --add item apple left \
  --set apple \
    icon=󰀵 \
    icon.color=$PINK \
    icon.font="JetBrainsMono Nerd Font:Bold:17.0" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.drawing=off \
    $POPUP_PROPS \
    popup.align=left \
    script="$PLUGIN_DIR/apple.sh" \
  --subscribe apple mouse.clicked mouse.entered mouse.exited mouse.entered.global mouse.exited.global

ROW_PROPS="icon.padding_left=10 label.padding_right=12 background.corner_radius=6 background.drawing=off"

add_header() { # name label
  sketchybar --add item "apple.$1" popup.apple \
    --set "apple.$1" icon.drawing=off background.drawing=off label="$2" \
      label.color=$PURPLE label.font="JetBrainsMono Nerd Font:Bold:10.0" \
      label.padding_left=12 label.padding_right=12
}

add_row() { # name icon label click_cmd [keep_open]
  local close="; sketchybar --set apple popup.drawing=off"
  [ "$5" = "keep_open" ] && close=""
  sketchybar --add item "apple.$1" popup.apple \
    --set "apple.$1" icon="$2" icon.color=$CYAN label="$3" $ROW_PROPS \
      script="$PLUGIN_DIR/popup_row.sh" \
      click_script="$4$close" \
    --subscribe "apple.$1" mouse.entered mouse.exited
}

# ---- system ----
add_row about    󰍹 "About This Mac"   "open -a 'System Information'"
add_row settings 󰒓 "System Settings…" "open -a 'System Settings'"
add_row lock     󰌾 "Lock Screen"      "pmset displaysleepnow"
add_row sleep    󰐥 "Sleep"            "pmset sleepnow"
add_row reload   󰑓 "Reload SketchyBar" "sketchybar --reload"

FS_LABEL=$([ -f "$CONFIG_DIR/.fs_guard_off" ] && echo "Fullscreen Guard: OFF" || echo "Fullscreen Guard: ON")
add_row fsguard 󰊓 "$FS_LABEL" 'CFG="$HOME/.config/sketchybar"; if [ -f "$CFG/.fs_guard_off" ]; then rm "$CFG/.fs_guard_off"; sketchybar --set apple.fsguard label="Fullscreen Guard: ON"; else touch "$CFG/.fs_guard_off"; sketchybar --set apple.fsguard label="Fullscreen Guard: OFF"; fi' keep_open

# ---- themes (hot-swap) ----
add_header themehead "THEME"
CURRENT_THEME=$(cat "$CONFIG_DIR/.theme" 2>/dev/null || echo vice-city)
for t in vice-city cyberpunk matrix catppuccin miami-sunset; do
  MARK="○"; [ "$t" = "$CURRENT_THEME" ] && MARK="●"
  add_row "theme_$t" 󰏘 "$MARK $t" "echo $t > \$HOME/.config/sketchybar/.theme; sketchybar --reload"
done

# ---- widget toggles ----
add_header widgethead "WIDGETS"
for w in network caffeine ports pomodoro github weather speedtest meeting focus temps media; do
  MARK="○"; widget_on "$w" && MARK="●"
  add_row "widget_$w" 󰨝 "$MARK $w" "CFG=\$HOME/.config/sketchybar; if grep -q '^$w=on' \$CFG/widgets.conf; then sed -i '' 's/^$w=on/$w=off/' \$CFG/widgets.conf; else sed -i '' 's/^$w=off/$w=on/' \$CFG/widgets.conf; fi; sketchybar --reload"
done

# ---- revert ----
add_header reverthead " "
add_row revert 󰩈 "Revert to macOS bar" "$PLUGIN_DIR/revert.sh"
sketchybar --set apple.revert icon.color=$RED label.color=$RED
