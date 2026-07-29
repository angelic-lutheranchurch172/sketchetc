#!/bin/bash
# Pull the release branch, rebuild helpers, reload, then show what shipped.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export CONFIG_DIR
source "$CONFIG_DIR/plugins/settings_lib.sh"

APP=$(dirname "$(readlink "$HOME/.config/sketchybar" 2>/dev/null || echo "$CONFIG_DIR")")
CHANNEL=$(setting channel); CHANNEL=${CHANNEL:-production}

OLD=$(cat "$APP/VERSION" 2>/dev/null || echo "0.0.0")
if ! git -C "$APP" pull --ff-only --quiet origin "$CHANNEL" 2>/dev/null; then
  "$CONFIG_DIR/plugins/notify.sh" update "Update failed" "Could not fast-forward. Run: git -C $APP status"
  exit 1
fi

# helpers are gitignored binaries, so rebuild whatever changed
if command -v swiftc >/dev/null; then
  for s in "$APP/config/plugins/bin/"*.swift; do
    [ -e "$s" ] || continue
    swiftc -O -o "${s%.swift}" "$s" 2>/dev/null
  done
fi

NEW=$(cat "$APP/VERSION" 2>/dev/null || echo "$OLD")
rm -f "$CONFIG_DIR"/.update_notified_* "$CONFIG_DIR/.update_skip"
sketchybar --reload
sleep 2
"$CONFIG_DIR/plugins/notify.sh" update "sketchetc updated" "Now on v$NEW"
echo "$NEW" > "$CONFIG_DIR/.last_seen_version"
"$CONFIG_DIR/plugins/release_open.sh" "$OLD" &
