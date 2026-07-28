#!/bin/bash
# journal_actions.sh setup|draft|finalize|view|browse|copy <range>|verify
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
    osascript -e 'display notification "Journal ready. Write your first update from the journal menu." with title "Journal"'
    ;;
  draft)
    # centered overlay editor (custom dark window, 720x520)
    TEXT=$("$CONFIG_DIR/plugins/bin/entry_box" "Today's update · $(date '+%A, %d %B')" "- ") || exit 0
    [ -z "$(echo "$TEXT" | tr -d ' \n-')" ] && exit 0
    {
      [ -s "$JDRAFT" ] && echo
      echo "**$(date '+%H:%M')**"
      echo
      echo "$TEXT" | sed '/^[[:space:]]*-[[:space:]]*$/d'
    } >> "$JDRAFT"
    osascript -e 'display notification "Added to today. Finalize from the journal menu when done." with title "Journal"'
    ;;
  finalize)
    if [ ! -s "$JDRAFT" ]; then
      osascript -e 'display dialog "No draft written yet. Finalize with an empty entry?" buttons {"Cancel","Finalize empty"} default button "Cancel"' 2>/dev/null | grep -q Finalize || exit 0
    fi
    jfinalize
    ;;
  view)
    ROOT=$(jroot)
    CHOICES=$(find "$ROOT" -name '*.md' | sort -r | head -14 | while read -r f; do
      rel="${f#"$ROOT"/}"
      echo "${rel%.md}" | tr '/' '-'
    done)
    [ -z "$CHOICES" ] && { osascript -e 'display notification "No entries yet" with title "Journal"'; exit 0; }
    PICK=$(osascript -e "choose from list {$(echo "$CHOICES" | sed 's/^/"/; s/$/"/' | paste -sd, -)} with prompt \"View which day?\"" 2>/dev/null)
    [ "$PICK" = "false" ] || [ -z "$PICK" ] && exit 0
    qlmanage -p "$ROOT/$(echo "$PICK" | tr '-' '/').md" >/dev/null 2>&1 &
    ;;
  browse)
    open "$(jroot)"
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
