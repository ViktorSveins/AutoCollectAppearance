# AutoCollectAppearance

A tiny addon for [Project Ascension](https://ascension.gg) (3.3.5 client) that auto-accepts the
`CONFIRM_COLLECT_APPEARANCE` popup shown when you ctrl-alt-click an item to collect its transmog appearance.

## Install

Extract (or clone) the `AutoCollectAppearance` folder into:

```
C:\Ascension\Launcher\resources\ascension-live\Interface\AddOns\
```

so you end up with `...\AddOns\AutoCollectAppearance\AutoCollectAppearance.toc`.

Enable it in the AddOns list at the character select screen.

## Usage

- Ctrl-alt-click gear as usual — the confirmation popup is accepted instantly.
- `/aca` toggles the auto-accept on/off in-game.
- `/aca bags` sweeps bags 0-4 and collects the appearance of every item whose look you don't own yet.
- On first login the addon creates a per-character macro **CollectLooks** (body: `/aca bags`) — drag it to a bar for one-click bag sweeps.

## Warning

Collecting an appearance consumes the item. This addon removes the confirmation safety net,
and `/aca bags` will consume **every** bag item with an uncollected look — including gear you
might still want to wear or sell. Only use it while intentionally farming transmog.
