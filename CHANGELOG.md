# Changelog

All notable changes to It Just Works™ are recorded here. This project follows
[Semantic Versioning](https://semver.org/); see [docs/VERSIONING.md](docs/VERSIONING.md)
for what the numbers mean for a mod. The top heading's version must match `VERSION` -
the build gate checks it.

## 0.3.1

- **SEQ file shipped (packaging hygiene).** Start-game-enabled quests are supposed to come with a
  small `SEQ` list so the engine knows to start them on existing saves. We ship one now - standard
  Skyrim packaging. Mid-playthrough install was already tested for hours on a real load order; the
  quest came up fine every time, so this is extra safety for odd setups and for people who never
  open the menu - not a fix for a break we were hitting in normal play.
- **Doc fixes.** The README's alert example matches the shipped wording again; the manual's Watchdog
  list and the MCM status help document the **Late** state (alive, but a check came in slower than
  its interval).

## 0.3.0

- **The mod shows its work.** The single on/off "Log to Papyrus" toggle becomes a three-level
  **Diagnostics log** - Off / Events / Every check - and everything it writes is now a
  structured, greppable line (`[fth_IJW] <tag> <event> key=value`). Every state change and,
  for the first time, every one of the mod's silent self-corrections leaves a trace - above all
  the re-sync that keeps a scene stuck across a reload from going unnoticed.
- **See it heal itself without a log.** The Diagnostics page gains a **Watchdog** status
  (Running / Waking up / Off / Dormant / Late - is the background check alive?) and a **Last
  self-repair** line, so you can confirm the tool is working, and see the last thing it fixed,
  without ever opening the Papyrus log.
- **Fixed a quiet bug.** A logging call could fire the one-time "names are off" notice even with
  logging turned off, because Papyrus builds a call's arguments before checking the switch.
  Logging is now genuinely silent - and free - when off.
- **Manual:** a short "Watching it work" section, including how to switch the Papyrus log on.

## 0.2.4

- **Tighter watchdog alert.** The status line is now telegraphic - it has to land at a
  glance before Skyrim shrinks a long notification. `In a scene ~3m; blocking others.`
  becomes `scene blocking others ~3m`. The punchline stays exactly where it belongs.

## 0.2.3

- **English fallback preserved.** Choosing a non-English default menu language now also
  drops an English `.bak` sidecar (`fth_ItJustWorks_ENGLISH.txt.bak`), so the English menu
  can be restored by renaming one file instead of reinstalling.
- **Localized installer descriptions.** The FOMOD option tooltips are now written in each
  option's own language, not English - the reader who wants a non-English menu can read the
  one caveat that makes it work.
- **Clearer manual.** Each manual now opens with a short "what this does, and why," and the
  display-language section names both installer steps (tick the language in step one, then
  choose it as your default in step two).
- **Mod page linked.** The Nexus page URL is stamped into the FOMOD metadata.
- **Build hygiene.** Reworded a template comment that shipped as a dangling fragment in
  `fomod/info.xml`, and the verify gate now also proves the default-language flag links,
  overwrite priority, and English `.bak` are all in place.

## 0.2.2

Packaging and docs - the mod's runtime behavior is unchanged.

- **Default menu language (installer).** The FOMOD gained a second step: choose which
  language the menu shows by *default*. Skyrim loads the translation that matches the
  game's language setting, so on an English-language install a non-English menu would
  otherwise stay English. Picking a language here writes it over the English file the
  game reads (installing both files), so the menu shows through whatever the game's
  language is. English stays the default; every other option is greyed out until you
  tick its file in the first step.
- **Display-language note.** The README and all ten manuals now explain the above and
  its by-hand workaround - renaming your language's file to `fth_ItJustWorks_ENGLISH.txt`.
- **Build.** The FOMOD generator and its verify gate were updated for the two-step
  installer.

## 0.2.1

Build tooling only - no change to the mod itself. Compiled `.pex` timestamps are now
controlled by the `SOURCE_DATE_EPOCH` convention instead of a fixed constant: the build
uses `SOURCE_DATE_EPOCH` when set, otherwise the HEAD commit date on a clean tree, otherwise
the current build time - announcing which it used. This makes the compile timestamp coherent
and honest. (Full byte-reproducibility isn't claimed: the Papyrus compiler's output isn't
deterministic, which no header rewrite can fix - coherent timestamps are as close as the
current tools allow.)

## 0.2.0

First public release. A scene watchdog and debug menu for the stuck-state bug - the
switch Skyrim forgets to flip back.

- **Scene watchdog.** Polls the scene you're in (every 30s by default, tunable 10-240s
  or off) and fires a single advisory notification once you've been in one past a
  threshold (3 minutes by default, or never). You never have to remember to check.
- **Stop Scene.** The fix: ends a scene you're stuck in, with a deliberate two-step
  confirm so it can't misfire on a working one.
- **A live readout.** The current scene, its owning quest and form ID, a rough
  time-in-scene, and the last ten scenes you passed through.
- **A rebindable hotkey** that names your current scene without opening the menu, with
  a Clear button to unbind it.
- **Enable/disable.** Shelve the whole mod mid-playthrough without uninstalling - it
  goes dormant and restores exactly, no cleanup and no lost state.
- **Diagnostics.** An "Editor IDs loaded" status light (names vs. ID numbers, via po3
  Tweaks) and a Papyrus-log toggle for troubleshooting.
- **Built to be safe.** ESL-flagged, alias-free, save-safe to add and to remove, and
  self-healing across reloads.
- **Ten languages.** Menu and manual in English plus nine more - Chinese, Czech,
  French, German, Italian, Japanese, Polish, Russian, Spanish - each chosen at install
  through a FOMOD picker, so only what you pick touches your Data folder. Non-English
  is machine-translated; corrections welcome.
- **Documented.** An in-game manual in every language, plus a technical and build
  writeup in the repository.
