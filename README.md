# ZaiiaPawn

Multi-set item scoring for Turtle-like servers.

Inspired by and based on OctoPawn, most of the code was rewritten,
only the class presets are reused from the original.

ZaiiaPawn scores items against your own weight sets and shows the
result directly in item tooltips and on the character / inspect sheet.

ClassicAPI and SuperWoW are recommended for the full feature set,
but the addon works without them (see "Optional dependencies" below).


## Features

- Multiple weight sets.
  Define as many sets as you want (Holy, Protection, Retribution,
  Feral Cat, Marksmanship, Leveling, ...). Each set is a table of
  STAT = weight.

- Per-class presets.
  Ready-made ZaiiaPawn presets for Paladin, Hunter and Druid, plus
  the classic OctoPawn defaults for every class.

- Tooltip scores.
  Active sets are shown on item tooltips with an optional diff
  against the currently equipped item.

- Character sheet + inspect.
  Equipped gear is scored for your own character and (via the
  Inspect window) for other players.

- Equipment filters.
  Per set, block specific weapon or armour types (Two-Hand, Shields,
  Wands, Holdables, ...) so they are ignored during scoring.

- Soft caps (diminishing returns).
  Per-stat caps configurable from the Advanced window: past the cap,
  extra points count less.

- Pawn v1 import / export.
  Share or import weight sets using the standard Pawn string format
  (WoWhead-compatible).

- Full profile backup.
  Export every set (weights + equipment filters) into one portable
  string; import it on another character of the same class.

- Weapon type preferences.
  Score contribution for 1H, 2H, Shield, Off-hand, Ranged — soft
  preference, independent from the hard equipment filter.


## Interface
<img src="https://github.com/user-attachments/assets/3dd08e51-6943-40c9-978e-f3e90797b29a" />

Open the main window with /zp or the minimap icon.

- Left-click a set name — open its weights in a side window.
  Click again to close.
- Right-click a set name — mark it as active (green *).
  The active set is what you are editing and what gets exported.
- Checkbox — show / hide the set in item tooltips and in the
  character sheet scoring.
- ^ / v — reorder sets.
- Esc — close windows.

Buttons on the right are grouped into Set, Global and Options.


## Installation

1. Download or clone this repository.
2. Place the folder into Interface/AddOns/ZaiiaPawn/.
   If the folder is named "ZaiiaPawn-master" (GitHub default),
   rename it to "ZaiiaPawn" — without the "-master" suffix.
3. Restart the client (or /reload).


## Optional dependencies

ClassicAPI and SuperWoW are auto-detected. Installing them is
recommended — without them the addon still runs, but some features
degrade.

- [ClassicAPI](https://github.com/brues-code/ClassicAPI) — numeric classID / subclassID for items.
  Without it: exact byClassSubclass equipment filters (Wands, Maces,
  Shields, Librams, Idols, Totems) are silently skipped. byEquipLoc
  filters (Two-Hand, Ranged, Holdable, Off-hand) still work.

- [SuperWoW](https://github.com/balakethelock/SuperWoW) — better mouseover resolution.
  Without it: tooltip scoring for other players is limited to your
  party members 1-4, your target and yourself. Raid members are not
  detected.


Credits

- Original [OctoPawn by iGreed](https://github.com/iGreed1993/OctoPawn),
  reused class weight presets and the equipment filter format
  as a starting point.

- ZaiiaPawn — rewritten and extended:  new tooltip  engine,
  multi-set active system, soft caps, equipment filter
  dialog, full-profile export/import, UI rework.
