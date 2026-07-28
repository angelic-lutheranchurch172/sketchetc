#!/bin/bash
# Record a demo of the bar: run this, then click around (popups, theme swap,
# Clear RAM) for 20 seconds. Produces assets/demo.mov (+ demo.gif if ffmpeg exists).
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/assets/demo.mov"
echo "Recording 20s — click around the bar now!"
screencapture -v -V 20 "$OUT"
echo "Saved $OUT"
if command -v ffmpeg >/dev/null; then
  ffmpeg -y -i "$OUT" -vf "fps=15,scale=1280:-1:flags=lanczos" -loop 0 "$REPO/assets/demo.gif" \
    && echo "Saved assets/demo.gif"
else
  echo "Install ffmpeg (brew install ffmpeg) to also produce a GIF."
fi
