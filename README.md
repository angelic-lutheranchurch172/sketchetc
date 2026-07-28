# sketchetc

My macOS menu bar, rebuilt with [SketchyBar](https://felixkratz.github.io/SketchyBar/) — GTA Vice City colors (hot pink · neon cyan · sunset orange on deep night-purple), JetBrains Mono Nerd Font, fully interactive.

![topbar](assets/topbar.png)

## Features

| Item | Click |
|---|---|
| 󰀵 Apple menu | About / Settings / Lock / Sleep / Reload / Fullscreen-guard toggle |
| Spaces 1–4 | Switch desktop (⌃1–⌃4 under the hood) |
| Front app | Popup listing running apps — click to switch |
| Now playing | Play/pause; right-click for ⏮ ⏯ ⏭ |
| 󰚩 AI agents | Counts running claude/codex/gemini processes; popup lists them |
| Volume | Popup with live drag slider; scroll the icon to nudge |
| Wi-Fi | IP, toggle Wi-Fi, Network Settings |
| Battery | Time remaining + cycle count |
| CPU / RAM pill | Top-5 processes; **Clear RAM** button (safely reaps orphaned helpers + purge, then speaks the result) |
| Clock | Calendar with today highlighted |

Behaviors that make it feel native:

- **Reserved space** — windows tile below the bar, never behind it (bar draws over the native menu bar's reserved strip).
- **Fullscreen guard** — fullscreening any app auto-converts it to a fill-below-the-bar window; toggle off from the 󰀵 menu for real fullscreen.
- **One popup at a time**, closes on outside click / app switch / mouse-out. Hover glows, animated everything.

## Install (fresh Mac)

```bash
git clone https://github.com/himanshu007-creator/sketchetc.git
cd sketchetc && ./install.sh
```

Grant the two permissions macOS asks for (Accessibility + Automation for sketchybar) and you're done.

## Layout

```
config/
├── sketchybarrc   # bar geometry + defaults
├── colors.sh      # Vice City palette
├── items/         # one file per widget (creation + subscriptions)
└── plugins/       # logic (bash) + bin/mouse_info (tiny Swift helper)
```

`~/.config/sketchybar` is a symlink to `config/`, so live tweaks are repo edits. See `CLAUDE.md` for conventions and the macOS quirks this setup works around.

## Credit

Built on [FelixKratz/SketchyBar](https://github.com/FelixKratz/SketchyBar) · app icons from [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font).
