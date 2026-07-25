# It Just Works™

**Skyrim Special Edition / AE** — ESL-flagged scene watchdog and debug menu.

Stuck scenes (dialogue, cutscenes, scripted moments) can stay “playing” forever and block later scenes with no error and no crash. This mod watches the player’s current scene, warns when you’ve been in one too long, names what you’re in, and gives you a Stop Scene button when you’re stuck.

| | |
|--|--|
| **The meta** (why this exists) | [docs/THE_META.md](docs/THE_META.md) |
| **In-game how-to** | [docs/manual.md](docs/manual.md) · [all languages](TRANSLATIONS.md) |
| **Design** | [DESIGN.md](DESIGN.md) |
| **Build** | [docs/BUILDING.md](docs/BUILDING.md) |
| **Architecture** | [docs/README.md](docs/README.md) |

---

## Features

| | |
|--|--|
| **Watchdog** | Polls current scene (default 30s); one advisory toast after a threshold (default 3 min) |
| **Stop Scene** | Two-step confirm in the MCM; runs when the menu closes |
| **Readout** | Scene name / form ID / owning quest, time-in-scene (session wallclock), last 10 scenes |
| **Hotkey** | Optional bind: name current scene without opening the menu |
| **Settings** | Enable/disable (dormant without uninstall), Levity (copy only), Notification language, poll/warn dials, diagnostics log |
| **Safety** | Alias-free quest, mid-playthrough add/remove, SEQ for start-on-load, holds no world state |
| **Languages** | MCM + manuals + corner toasts in 10 languages; FOMOD can seed toast language with default menu language |

## Requirements

- [SKSE64](https://skse.silverlock.org/)
- [MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)
- [powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)
- [powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073) — soft but recommended: `Load EditorIDs = true` in `po3_Tweaks.ini` (names instead of raw IDs)

Optional: a font mod if menu/toasts use non-Latin scripts (stock Skyrim fonts cannot draw them), e.g. [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346).

ESL-flagged (no load-order slot). Safe to add and remove mid-playthrough. A watchdog; it holds nothing.

## Install

Mod manager + FOMOD preferred. English always ships; optional language files and optional default menu language (seeds Notification language). Launch via SKSE. Safe on an ongoing save.

## Uninstall

1. MCM → Settings → Enabled → **Off**  
2. Save, quit  
3. Remove the mod  

Optional save cleaner (e.g. ReSaver) only if you know what you’re doing — not required. Details in the manual.

## The rest of the toolkit

This mod does one thing: the stuck scene. It doesn’t do the rest, because better mods already do. Keeping a save alive is a team sport. If you’re serious about it, run these too:

- **[USSEP](https://www.nexusmods.com/skyrimspecialedition/mods/266)** — prevention. Fixes thousands of bugs before they ever bite.
- **[SSE Engine Fixes](https://www.nexusmods.com/skyrimspecialedition/mods/17230)** and **[Bug Fixes SSE](https://www.nexusmods.com/skyrimspecialedition/mods/33261)** — the engine-level papercuts most people never diagnose.
- **[Crash Logger](https://www.nexusmods.com/skyrimspecialedition/mods/59818)** — so a crash tells you *what*, not just *that*.
- **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** (FallrimTools) — cleans script gunk out of a save. Powerful, and a genuine footgun; know what you’re doing before you point it at a save you love.

### Kindred spirits

Not requirements — just proof you’re not imagining it.

- **[Reset Random Dialogue Scenes](https://www.nexusmods.com/skyrimspecialedition/mods/34961)** — someone else who noticed scenes stick, and built a quiet weekly reset for one flavor of it.
- **[Debug Menu - Navmesh Viewer](https://www.nexusmods.com/skyrimspecialedition/mods/136456)** — another debug menu for a game that doesn’t need one.

## Build (developers)

```text
# prerequisites: .NET 10, PapyrusCompiler, Skyrim SE install, headers (see docs/BUILDING.md)
.\build.ps1
```

One entry point: ESP (Mutagen) → Papyrus compile (toast bake + pex string replace) → identity scrub → FOMOD → verify → zip. Details: [docs/BUILDING.md](docs/BUILDING.md).

## Repo map

| Path | |
|------|--|
| `scripts/` | Papyrus (`fth_IJW_Watcher`, `fth_IJW_MCM`; toasts generated at build) |
| `src/` | Builder (ESP), PexScrub |
| `mcm/Config/fth_ItJustWorks/` | MCM layout + Config defaults |
| `interface/translations/` | UTF-16 LE string tables (10 languages) |
| `docs/` | Manuals, THE_META, BUILDING, technical overview |
| `ideas/` | Design notes |
| `DESIGN.md` | Principles and practices |
| `CHANGELOG.md` / `VERSION` | Release history |

## License

[MPL-2.0](LICENSE.txt). Name/logo terms: [NOTICE.md](NOTICE.md).

Ryan Gubele — source in [the repository](https://github.com/ryangubele/ItJustWorks).

Thanks to the MCM Helper and powerofthree teams, whose work this is built on. And to the authors of the rest of the toolkit up there — USSEP, ReSaver, the engine fixers and the others — because keeping a save alive is a team sport.
