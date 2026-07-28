#!/bin/bash
# Fullscreen guard: native fullscreen always spans every pixel (nothing can
# reserve space there), so convert fullscreen windows into fill-below-the-bar
# windows. Toggle off via the apple menu (flag file) for real fullscreen (video).
# ponytail: primary display only, front window only.
[ -f "$CONFIG_DIR/.fs_guard_off" ] && exit 0

osascript <<'AS' 2>/dev/null
tell application "Finder" to set {_, _, screenW, screenH} to bounds of window of desktop
tell application "System Events"
  set p to first application process whose frontmost is true
  if (count of windows of p) is 0 then return
  set w to window 1 of p
  if value of attribute "AXFullScreen" of w is true then
    set value of attribute "AXFullScreen" of w to false
    delay 1.4
    set position of w to {0, 30}
    set size of w to {screenW, screenH - 30}
  end if
end tell
AS
exit 0
