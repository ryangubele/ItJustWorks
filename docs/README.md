# It Just Works - technical overview

Developer-facing notes for reading, building, or forking the mod. The root
[README](../README.md) is the player-facing pitch; this is the map under it.
Design rationale lives in [DESIGN.md](../DESIGN.md); the in-game guide is
[manual.md](manual.md); build steps are in [BUILDING.md](BUILDING.md); the version
policy is in [VERSIONING.md](VERSIONING.md).

## What it is, technically

An ESL-flagged plugin with a single `QUST` record (master: `Skyrim.esm`), generated
from code by Mutagen - no Creation Kit authoring, so the plugin diffs in git and
rebuilds byte-for-byte. Two Papyrus scripts ride the quest's VMAD:

- **`fth_IJW_Watcher`** (extends `Quest`) - the engine. A single-update poll loop
  reads the player's current scene, keeps a small state (current scene, first-seen
  time, a 10-entry history ring), fires one advisory notification past a threshold,
  owns the rebindable hotkey (`RegisterForKey`), the enable/disable master switch,
  and the Stop-scene action. All of its state persists in the save.
- **`fth_IJW_MCM`** (extends `MCM_ConfigBase`) - the menu glue. Thin: it pushes the
  watcher's live state into the ModSettings the menu displays and wires the buttons.
  Both scripts sit on the same quest, so `Self as fth_IJW_Watcher` reaches the sibling.

The menu itself is data: **MCM Helper** renders it from `mcm/Config/fth_ItJustWorks/`
(`config.json` = layout, three pages - Scene, Diagnostics, Uninstall; `settings.ini`
= ModSetting defaults). Labels come from the `interface/translations/*.txt` string
tables (UTF-16LE, ten languages).

## Settings model

Settings are **MCM Helper ModSettings** - stored on disk in `MCM\Settings\`, seeded
from the shipped `settings.ini`. That makes them independent of both the save and the
deploy. The watcher holds a live in-memory mirror; **disk is the source of truth**,
and the MCM reconciles the two (idempotently) every time the menu opens. Setting IDs
use MCM Helper's `key:Section` form, matching the `[Section]` blocks in `settings.ini`.

## Repo map

| Path | What |
|------|------|
| `scripts/` | Papyrus source - the two `.psc` above |
| `src/` | C# build tools: **Builder** (Mutagen ESP), **PexScrub** (`.pex` identity strip) |
| `headers/` | Third-party Papyrus API stubs (MCM Helper, po3, SkyUI, base signatures) - gitignored, not redistributed; supply your own (see BUILDING.md) |
| `mcm/Config/fth_ItJustWorks/` | The menu: `config.json`, `settings.ini` |
| `interface/translations/` | MCM string tables, UTF-16LE, 10 languages |
| `packaging/` | FOMOD + license-breadcrumb templates |
| `docs/` | Manuals (10 languages), `BUILDING.md`, this |
| `sanitization/` | Public README + inert sample; real identity checks live gitignored in `private/` |
| `assets/` | `logo.svg` |
| `build.ps1` | The single build entry point |

Project meta at the root: `DESIGN.md`, `NOTICE.md` (name/logo terms), `LICENSE.txt`
(MPL-2.0), `TRANSLATIONS.md`, `CHANGELOG.md`, `VERSION`.

## Build pipeline

`build.ps1`: generate ESP (Mutagen) -> compile Papyrus -> scrub `.pex` identity ->
assemble the Data-rooted tree -> stamp metadata + generate the FOMOD -> verify gate
-> zip. The verify gate fails the build on a version mismatch across surfaces, a
dangling FOMOD reference, or (unless `-SkipSanitization`) a failed identity check.
Full prerequisites and options: [BUILDING.md](BUILDING.md).

`PexScrub` matters for privacy: a compiled `.pex` embeds the building machine's
username and hostname in plaintext. It replaces them with fixed constants and pins
the compile timestamp (which also makes builds reproducible).

## Runtime dependencies

To run (not to build): **SKSE64**, **MCM Helper**, **powerofthree's Papyrus
Extender**, and **powerofthree's Tweaks** with `Load EditorIDs = true` in
`po3_Tweaks.ini` (that last one is what lets scenes and quests read as names instead
of form IDs; the mod works either way).

## Invariants worth knowing before you change things

- **`IsPlaying()` is not a stuck-detector** - it stays true for stuck scenes. It's
  only a gate against already-ended scenes; **duration** is the signal that something
  is stuck.
- **The plugin is alias-free**, on purpose - it force-persists nothing, so removal is
  clean. The cost: a `Quest` script gets no `OnPlayerLoadGame`, so the poll loop
  re-registers itself each tick and the MCM re-asserts the timer + hotkey on open.
  That "open the menu to self-heal" is deliberate; don't add a `ReferenceAlias` to
  avoid it.
- **ESL range**: every FormID must stay in `0x800-0xFFF`. The Builder fails loud if
  Mutagen ever allocates outside it.
