# Aura points

Effort, made visible. The 󱠇 widget tracks how hard you're actually working and
turns it into a score you can flex.

## How you earn

**Pomodoro aura** (the real money): finish a 25-minute 󰔛 timer and the session
is scored on what actually happened during it — all measured locally with
zero-permission macOS counters:

```
50 base
+ keystrokes / 100   (max 50)
+ clicks / 50        (max 20)
+ 10 × AI agents running (max 30)
+ 25 × PRs you opened during the session
= capped at 200 per pomodoro
```

Awards are celebrated: notification + spoken voice + the widget flashes `+N ✨`
and fades back to your running total.

**Passive aura**: every 30 minutes, meaningful typing (>500 keys) earns +5 —
capped at 2000/day so the leaderboard can't be farmed by keyboard mashing.

## Reviewing & sharing

Click 󱠇 → today / 7-day / 30-day totals, plus **Export day / week / month /
year** — each renders a shareable PNG card (theme-colored gradient, your number,
a bar chart of the period) into `~/Downloads`. Cards carry
"generated via github.com/himanshu007-creator/sketchetc".

Data lives in plain CSVs at `~/.local/share/sketchetc/aura/` — yours to grep.
