# Roadmap

Free and open-source, always. Rough order:

- **Fan control (read stays, write won't ship by default)** — the temps widget
  already shows fan RPM where hardware has one. Actively *setting* fan curves
  requires root SMC writes; a menu bar config silently overriding thermal
  management is exactly the kind of thing that makes people afraid to install
  dotfiles, so if this ever lands it will be an explicit opt-in script, never a
  default.
- **Album-art tinted media widget** — sample the artwork's dominant color via a
  small Swift/AppKit helper (same pattern as `bin/mouse_info`) and tint the
  now-playing pill with it.
- **Per-agent token burn** — the AI-agents popup shows uptime/CPU today; parse
  local agent session logs to add token counts per running agent.
- **Demo GIF** — `scripts/record_demo.sh` exists; needs a human clicking while
  it records.
- **More themes** — PRs welcome: a theme is a 12-line file in `config/themes/`.
- **Focus state indicator** — currently a toggle button; reading the active
  Focus mode reliably across macOS versions needs more research.
