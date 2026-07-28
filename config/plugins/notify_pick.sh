#!/bin/bash
# choose a custom notification sound, or revert to the system default
CONF="$HOME/.config/sketchybar/.notify_sound"
CHOICE=$(osascript -e 'button returned of (display dialog "Notification sound:" buttons {"Cancel", "System default", "Choose file…"} default button "Choose file…")' 2>/dev/null)
case "$CHOICE" in
  "Choose file…")
    F=$(osascript -e 'POSIX path of (choose file with prompt "Pick an audio file" of type {"public.audio"})' 2>/dev/null)
    [ -z "$F" ] && exit 0
    echo "$F" > "$CONF"
    "$HOME/.config/sketchybar/plugins/notify.sh" "sketchetc" "This is your new notification sound"
    ;;
  "System default")
    rm -f "$CONF"
    "$HOME/.config/sketchybar/plugins/notify.sh" "sketchetc" "Back to the system default sound"
    ;;
esac
