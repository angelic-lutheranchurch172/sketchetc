#!/bin/bash
# journal_actions.sh setup|draft|finalize|copy <range>|verify
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/journal_lib.sh"

case "$1" in
  setup)
    ROOT=$(osascript -e 'POSIX path of (choose folder with prompt "Where should your journal live?")' 2>/dev/null)
    [ -z "$ROOT" ] && exit 0
    DAYS=$(osascript -e 'text returned of (display dialog "Working days (comma separated):" default answer "Mon,Tue,Wed,Thu,Fri")' 2>/dev/null)
    CUTOFF=$(osascript -e 'text returned of (display dialog "Day cutoff time (entries auto-lock after this):" default answer "21:00")' 2>/dev/null)
    mkdir -p "$(dirname "$JCONF")"
    printf 'root=%s\ndays=%s\ncutoff=%s\n' "${ROOT%/}" "${DAYS:-Mon,Tue,Wed,Thu,Fri}" "${CUTOFF:-21:00}" > "$JCONF"
    osascript -e 'display notification "Journal ready — write your first update from the 󱓧 menu" with title "Journal"'
    ;;
  draft)
    [ -f "$JDRAFT" ] || printf -- "- \n" > "$JDRAFT"
    open -t "$JDRAFT" 2>/dev/null || open "$JDRAFT"
    osascript -e 'display notification "Write in the draft, save, then hit Finalize in the 󱓧 menu" with title "Journal"'
    ;;
  finalize)
    if [ ! -s "$JDRAFT" ]; then
      osascript -e 'display dialog "No draft written yet — finalize with an empty entry?" buttons {"Cancel","Finalize empty"} default button "Cancel"' | grep -q Finalize || exit 0
    fi
    jfinalize
    ;;
  copy)
    jexport "$2" | pbcopy
    osascript -e "display notification \"$2 export copied as markdown\" with title \"Journal\""
    ;;
  verify)
    R=$(jverify)
    osascript -e "display notification \"$R\" with title \"Journal audit\""
    ;;
esac
