# AutoCollectAppearance

Addon for [Project Ascension](https://ascension.gg) (3.3.5 client) that auto-accepts the
`CONFIRM_COLLECT_APPEARANCE` popup when ctrl-alt-clicking an item to collect its transmog appearance.

## Install

Extract (or clone) the `AutoCollectAppearance` folder into:

```
C:\Ascension\Launcher\resources\ascension-live\Interface\AddOns\
```

so you have `...\AddOns\AutoCollectAppearance\AutoCollectAppearance.toc`, then enable it
in the AddOns list at character select.

## Usage

- Ctrl-alt-click gear as usual — the popup is accepted instantly.
- `/aca` toggles auto-accept.
- `/aca bags` sweeps bags 0-4 and collects every uncollected appearance.
- On first login a per-character macro **CollectLooks** (`/aca bags`) is created.

## Note

Collecting an appearance **soulbinds** the item (it is not consumed). `/aca bags` will bind
every bag item with an uncollected look, including items you meant to sell or trade.
