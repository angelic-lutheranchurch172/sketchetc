# Contributing

## Branches
- **develop** — default branch, all day-to-day work.
- **production** — what users install and update from. Only release merges land here.

## Releasing
```bash
git checkout develop
./scripts/release.sh patch "headline" "bullet one" "bullet two"
```
Bumps `VERSION`, prepends to `RELEASES.md`, regenerates the site data, merges into
`production` with a tag, pushes both branches, and creates the GitHub release.
Installed copies notice within six hours (or on their next reload).

## Adding a widget
See `WIDGETS.md`. The landing page picks new widgets up automatically —
`scripts/gen_site_data.sh` reads the live config, and a workflow reruns it on
every push to production.

## Licence

sketchetc is CC BY-NC-ND 4.0. Fork it and open a pull request here as much as
you like — that is welcome. What the licence rules out is distributing a
modified sketchetc as a separate release, or charging anyone for it.
