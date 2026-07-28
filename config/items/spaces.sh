#!/bin/bash
# ponytail: fixed 4 spaces; bump the loop if you use more
for sid in 1 2 3 4; do
  sketchybar --add space space.$sid left \
    --set space.$sid associated_space=$sid \
      icon=$sid \
      icon.color=$WHITE \
      icon.highlight_color=$PINK \
      icon.padding_left=9 \
      icon.padding_right=9 \
      label.drawing=off \
      script="$PLUGIN_DIR/space.sh" \
    --subscribe space.$sid mouse.clicked
done
