#!/bin/bash
# One folder holds every piece of user data. Set it once (Settings → Data folder
# or the journal menu) and journal entries, aura history and clipboard history
# all live under it, so a reinstall only has to point at the same folder again.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/settings_lib.sh"

DEFAULT_DATA="$HOME/.local/share/sketchetc/data"

data_dir() {
  local d
  d=$(setting data_dir)
  # compat: older installs kept a journal-only root in journal.conf
  if [ -z "$d" ]; then
    d=$(awk -F= '$1=="root"{print $2; exit}' "$HOME/.local/share/sketchetc/journal.conf" 2>/dev/null)
    [ -n "$d" ] && d="$d"
  fi
  echo "${d:-$DEFAULT_DATA}"
}
journal_root() { echo "$(data_dir)/journal"; }
aura_dir()     { echo "$(data_dir)/aura"; }
clip_dir()     { echo "$(data_dir)/clipboard"; }

data_ready() { # false when the folder vanished (external disk, deleted)
  local d; d=$(data_dir)
  [ -d "$d" ] && [ -w "$d" ]
}

data_ensure() {
  local d; d=$(data_dir)
  mkdir -p "$d/journal" "$d/aura" "$d/clipboard" 2>/dev/null
}

data_has_content() { # <dir> — does this look like a sketchetc data folder?
  [ -d "$1/journal" ] || [ -d "$1/aura" ] || [ -d "$1/clipboard" ]
}
