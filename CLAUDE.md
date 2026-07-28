# sketchetc — SketchyBar Vice City config

Personal SketchyBar setup. Reference docs: https://felixkratz.github.io/SketchyBar/

## Reinstall on a fresh Mac

Run `./install.sh`. It installs sketchybar + fonts via brew, symlinks `config/` to
`~/.config/sketchybar`, hides the native menu bar, enables ctrl+1..4 desktop hotkeys,
and starts the brew service. The user must grant Accessibility + Automation permissions
to `sketchybar` when macOS prompts.

## Layout

```
config/
├── sketchybarrc      # bar geometry (h=36, topmost=window, show_in_fullscreen=on), defaults, sources items/
├── colors.sh         # Vice City palette + shared $POPUP_PROPS
├── items/            # one file per widget: --add, subscriptions, static popup rows
└── plugins/          # update + event logic, one per widget (chmod +x, invoked by sketchybar with $NAME/$SENDER/$CONFIG_DIR)
```

## Conventions

- Every plugin starts with `source "$CONFIG_DIR/plugins/hover.sh"` then calls
  `hover` (animated border glow) and `close_popup_on_exit` (mouse.exited.global →
  closes ALL popups). `toggle_popup` enforces one-open-popup-at-a-time.
- Dynamic popup rows: `--remove '/<item>.<group>\..*/'` then re-add on each click,
  `background.drawing=off`, JetBrains Mono 12, `label.padding_left/right=12`.
  Hoverable rows use `plugins/popup_row.sh` + subscribe mouse.entered/exited.
- Colors: accents live in icons; labels are soft white 0xffe8e6f0 except
  warning states (orange >70%, red >85%). Alpha-muted purple borders.
- Palette: pink 0xffff6ec7 · cyan 0xff0bd3d3 · orange 0xffffa552 · purple 0xff9b5de5
  · bar 0xf2170a2e · pill 0xd9241640.

## macOS quirks learned the hard way

- `font-sf-pro` cask needs sudo → use JetBrains Mono Nerd Font instead (no sudo).
- macOS 26 redacts Wi-Fi SSID from CLI (returns literal `<redacted>`) → show connectivity only.
- `media_change` event is broken since macOS 15.4 → poll Spotify/Music via osascript.
- Bar needs `topmost=window` AND `show_in_fullscreen=on` to stay visible everywhere;
  sketchybar cannot reserve screen space (maximized windows tuck under the bar).
- In `--query` JSON the popup block nests `background.drawing` — read only the FIRST
  `drawing` after `"popup"` to get popup state (see `toggle_popup`).
- No `mouse.clicked.global` event exists; outside-click close = `mouse.exited.global`
  (subscribe `mouse.entered.global` too or delivery is unreliable).
- Newer Homebrew: `brew trust felixkratz/formulae` required before install.
- Space switching without a WM: enable symbolichotkeys 118–121 then osascript
  `key code (17+N) using control down`; requires Accessibility grant.

## After editing config

`sketchybar --reload` applies everything. Debug: run `sketchybar` in a terminal
foreground to see plugin stderr, or `sketchybar --query <item>`.
