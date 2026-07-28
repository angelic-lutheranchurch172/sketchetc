#!/bin/bash
# Revert to the native macOS menu bar (with confirmation). The native bar is
# already live underneath (reserved-space design) — stopping the service IS the
# revert. Bring sketchybar back anytime: brew services start sketchybar
CHOICE=$(osascript -e 'display dialog "Switch back to the native macOS menu bar?

SketchyBar will stop (the native bar is already underneath). Bring it back anytime with:
brew services start sketchybar" buttons {"Cancel", "Revert"} default button "Cancel" with icon caution' 2>/dev/null)

if [[ "$CHOICE" == *"Revert"* ]]; then
  osascript -e 'display notification "Restore anytime: brew services start sketchybar" with title "SketchyBar stopped"'
  brew services stop sketchybar
fi
