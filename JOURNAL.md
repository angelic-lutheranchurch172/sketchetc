# Journal — a tamper-evident daily work log

The 󱓧 widget is a mini audit system: one markdown entry per working day,
locked after your cutoff, provable later.

## Flow

1. **Setup** (once): pick a folder, your working days, and a daily cutoff time.
2. **Write today's update** → opens a draft in your editor.
3. **Finalize & lock** → the entry is written to `<root>/YYYY/MM/DD.md` with a
   generated header (date + that day's aura), hashed into the audit chain, and
   flagged immutable.
4. Forgot? At your cutoff on a working day it auto-finalizes (your draft if one
   exists, otherwise a "(no update logged)" stub — absence is also a record).

## The audit spine

- Every file gets `chflags uchg` — the macOS immutable flag. VS Code, vim,
  Finder, `rm`: all bounce off. There is no "edit yesterday".
- Every finalize appends to a **hash chain** (`index.log`): each line commits to
  the previous line's hash and the entry file's sha256. **Verify audit chain**
  in the popup re-checks everything.
- Honesty note: you own the machine, so `chflags nouchg` can unlock a file —
  but any modification breaks the chain and Verify says exactly where. Locked =
  can't edit by accident; chained = can't edit *undetectably*.

## Proving your work

Popup → **Copy day / week / month / year**: assembles the range as clean
markdown (`# Year → ## Month → ### Day`) onto your clipboard — paste into a
review doc, an email, wherever.
