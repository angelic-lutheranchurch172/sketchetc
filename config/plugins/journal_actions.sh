#!/bin/bash
# journal_actions.sh setup|open|copy <range>|verify|reset
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export CONFIG_DIR
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/journal_lib.sh"

line_input() { # title placeholder -> stdout
  "$CONFIG_DIR/plugins/bin/entry_box" --line "$1" "$2"
}

case "$1" in
  setup)
    ROOT=$(osascript -e 'POSIX path of (choose folder with prompt "Where should your journal live?")' 2>/dev/null)
    [ -z "$ROOT" ] && exit 0
    DAYS=$(line_input "Working days (comma separated)" "Mon,Tue,Wed,Thu,Fri") || DAYS=""
    CUTOFF=$(line_input "Day cutoff time (entries auto-lock after this)" "21:00") || CUTOFF=""
    mkdir -p "$(dirname "$JCONF")"
    printf 'root=%s\ndays=%s\ncutoff=%s\n' "${ROOT%/}" "${DAYS:-Mon,Tue,Wed,Thu,Fri}" "${CUTOFF:-21:00}" > "$JCONF"
    osascript -e 'display notification "Journal ready. Open it from the journal menu." with title "Journal"'
    ;;
  open)
    # detach: the window must outlive this click_script
    osascript -e "do shell script \"nohup $CONFIG_DIR/plugins/journal_open.sh > /dev/null 2>&1 &\""
    ;;
  copy)
    jexport "$2" | pbcopy
    osascript -e "display notification \"$2 export copied as markdown\" with title \"Journal\""
    ;;
  verify)
    R=$(jverify)
    osascript -e "display notification \"$R\" with title \"Journal audit\""
    ;;
  reset)
    CHOICE=$(osascript -e 'display dialog "Reset journal settings? Written entries stay locked on disk, only the folder, working days and cutoff are forgotten." buttons {"Cancel", "Reset"} default button "Cancel" with icon caution' 2>/dev/null)
    if [[ "$CHOICE" == *"Reset"* ]]; then
      rm -f "$JCONF" "$JDRAFT"
      osascript -e 'display notification "Journal settings cleared. Set up again from the journal menu." with title "Journal"'
      sketchybar --update
    fi
    ;;
esac
