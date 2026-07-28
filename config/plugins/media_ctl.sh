#!/bin/bash
# media_ctl.sh <prev|playpause|next> — drives whichever player is running
APP=""
pgrep -xq Spotify && APP="Spotify"
[ -z "$APP" ] && pgrep -xq Music && APP="Music"
[ -z "$APP" ] && exit 0

case "$1" in
  prev)      osascript -e "tell application \"$APP\" to previous track" ;;
  next)      osascript -e "tell application \"$APP\" to next track" ;;
  playpause) osascript -e "tell application \"$APP\" to playpause" ;;
esac
