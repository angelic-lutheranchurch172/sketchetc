#!/bin/bash
# Dual duty: hover handler for clipboard rows (image preview) + paste action.
source "$CONFIG_DIR/colors.sh"

if [ "$1" = "paste" ]; then
  FILE="$2"
  IS_IMG=0
  if [[ "$FILE" == *.png ]]; then
    osascript -e "set the clipboard to (read (POSIX file \"$FILE\") as «class PNGf»)"
    IS_IMG=1
  else
    pbcopy < "$FILE"
  fi
  sketchybar --set clipboard popup.drawing=off
  sleep 0.4   # let focus settle back on the target app (terminals are strict)

  # Terminals can't take images via ⌘V, but Claude Code's TUI reads a clipboard
  # image on Ctrl+V. So: image + terminal frontmost -> Ctrl+V, else ⌘V.
  MOD=cmd
  if [ "$IS_IMG" = "1" ]; then
    FRONT=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
    case "$FRONT" in
      Ghostty|ghostty|Terminal|iTerm2|kitty|Alacritty|alacritty|WezTerm|Warp) MOD=ctrl ;;
    esac
  fi

  # HID-level keystroke (cliclick) works where AppleScript keystrokes don't
  if command -v cliclick >/dev/null; then
    cliclick "kd:$MOD" t:v "ku:$MOD"
  else
    KEYMOD="command down"; [ "$MOD" = "ctrl" ] && KEYMOD="control down"
    osascript -e "tell application \"System Events\" to keystroke \"v\" using $KEYMOD" 2>/dev/null \
      || osascript -e 'display notification "Copied · press ⌘V to paste" with title "Clipboard"'
  fi
  exit 0
fi

# (hover highlighting for clipboard rows lives in popup_row.sh)
