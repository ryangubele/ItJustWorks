# Using It Just Works™

## What it does

Skyrim uses *scenes* for conversations, cutscenes, and other scripted moments. Sometimes a scene never ends. That can quietly block later scenes - a quest that won't move, no error, no crash. This mod watches the scene you're in, nudges you if you've been in one a while, shows you what it is, and lets you stop it if it's stuck.

**Short version:** leave the defaults on, keep playing. If you get a nudge, open **Mod Configuration Menu > It Just Works**.

It doesn't edit other mods' records or need patches, so load-order placement vs your content stack doesn't matter. It won't change a scene unless you tell it to stop.

Needs **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)**, and **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (with `Load EditorIDs = true` if you want names instead of ID numbers). Install notes are on the [mod page](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Five pages: **Scene**, **Watchdog**, **Settings**, **Diagnostics**, **Uninstall**.

---

## Scene

### What you're in

Readout of the current scene, or **None**. The menu is refreshed on opening.

- **Time in scene** - roughly how long you've been in this scene.
- **Scene** - name when available; otherwise an ID number.
- **Form ID** - the raw ID, always shown. Handy for the console or a bug report.
- **Owning quest** - which quest that scene belongs to.

### Stop Scene

If you believe the scene is stuck, this ends it.

1. Press **Stop Scene** once - a line confirms it's armed.
2. Press again to cancel, or close the menu to stop.

Only stop a scene you think is stuck. Stopping a normal one can break things. Stopping a stuck one can (rarely) fire a short burst of delayed events as the game catches up.

**Refresh** re-reads the current scene without closing the menu. In vanilla Skyrim, refresh is unlikely to be useful since the game pauses in menus. If you are running an unpause mod like [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), this lets you refresh without re-opening the menu.

### Recent scenes

Last ten scenes, newest first, with rough duration.

---

## Watchdog

Watches so you don't have to.

- **Warn me after** - how long a scene can run before you get a nudge. Default **6** minutes. **0** = never.  
  Nothing in the game marks a scene stuck, and nothing in the game tells us how long a scene is supposed to run. So we set a threshold and nudge you. We combine game time and save time in a way that roughly represents "time spent actually playing" so that the control is intuitive.
- **Check every** - seconds between checks. Default **30**. **0** = turn the watchdog off.
- **Repeat alerts** - off by default, so you get one nudge per scene. Turn it on to keep nudging while you're still over the threshold.
- **Repeat every** - minutes between nudges, used only when repeat alerts is on. Default **5**.

A nudge is two lines in the corner, for example:

> scene blocking others ~6m  
> See? It Just Works!

One nudge per scene by default, until you leave it or the scene changes. Missed it? Open the menu - the readout still shows what you're in and for how long. The mod does not stop the scene for you; use stop scene on the Scene page for that.

Unpause setups (e.g. [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) should work; played time still follows the game's saved play counter.

---

## Settings

- **Enabled** - on by default. Turn it off to shelve the mod without uninstalling.
- **Levity** - on by default. Notifications keep a light touch; turn it off for plain wording. Only the text changes, never how the mod works.
- **Notification language** - language for the mod's own corner notifications. The installer can seed this when you pick a default menu language; change it anytime on this page. English by default and as fallback; independent of the game's language setting.
- **Name current scene** - bind a key; press it to see the current scene name without opening the menu.
- **Clear hotkey** - removes the binding.
- **Diagnostics log** - how much goes to the Papyrus log. Leave **Off** for normal play. Use **Events** when filing a bug; **Every check** only if you're chasing a timing issue, then turn it back off. Can impact performance, especially at every check.

  Logging only works if the game is writing Papyrus logs. In `Documents\My Games\Skyrim Special Edition\`, edit `Skyrim.ini` or `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restart. Log file: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Search for `fth_IJW`.

---

## Diagnostics

- **Editor IDs loaded** - an indicator. Names on the Scene page and owning quest when lit; ID numbers when dark. Form ID is still the raw `0x…` either way.

- **Timing** - which clocks this scene is using for the warn threshold: played time plus game clock when both look sane, or played time only if the game clock dropped out for this scene. **--** when the watchdog is off, dormant, or you are not in a scene.

- **Watchdog** - whether the background check is up:
  - **Running** - fine
  - **Waking up** - normal right after a reload or before the first tick
  - **Late** - still working, but checks are slower than usual (busy game)
  - **Off** - you set check every to 0
  - **Dormant** - enabled is off on Settings

- **Last self-repair** - the mod sometimes fixes its own bookkeeping. A line here is normal.

- **Version**

---

## Troubleshooting

### Scenes show as ID numbers, not names

po3 Tweaks isn't loading Editor IDs. In `po3_Tweaks.ini`, set `Load EditorIDs = true` and restart Skyrim; the Diagnostics page's **Editor IDs loaded** light confirms it. Mod managers can overwrite that file on deploy or update, so edit the copy *inside* the Tweaks mod (or a small override mod that wins), not just a loose file in `Data`:

- **MO2:** the Tweaks mod folder in the left pane, or Overwrite / a higher-priority mod.
- **Vortex:** the Tweaks staging folder, or an override mod. Re-check after every update.

Form ID shows either way, so you're never fully in the dark.

### Notifications are in the wrong language

Corner notifications follow **Settings > Notification language**, not the game's language and not which menu translation file is installed. English is the default and the fallback.

A normal installer run that sets the default menu language also seeds this control so menu and notifications match. If you only swapped the menu file by hand, or upgraded without re-running that installer step, set notification language once to match your menu.

### The menu is in the wrong language

The MCM menu follows the game's language setting, not the notification language above. Skyrim loads the translation file that matches the game language, so an English game shows the English menu even if you installed another language. Two ways to change it:

- **Installer:** tick your language in step 1, then choose it as the default menu language in step 2. That overwrites the English menu file (and keeps an English `.bak`) **and** seeds notification language to match.
- **By hand:** rename `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` to `fth_ItJustWorks_ENGLISH.txt`, replacing the English file. That does **not** change notification language - set it on Settings to match, or notifications stay English.

### The menu or notifications show garbled or unreadable characters

The text is right - your game just has no font that can draw those characters, so it renders as garbage. Skyrim's stock font covers Latin and Western-European letters, but not Cyrillic, Chinese, Japanese, or some Central-European marks. If you run the menu or notifications in one of those, install a font mod that includes them; most non-English setups already have one. If yours doesn't, search Nexus for a font covering your language - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) is a broad starting point.

### No nudge ever appears

Check the Diagnostics page's Watchdog status, then the Watchdog dials:

- Status **Dormant** - the mod is off. Turn enabled on (Settings).
- Status **Off** - check every is 0. Set it back to 10-240s.
- Warn me after is **0** - that disables the nudge. Set the minutes you want.

The nudge waits on **both** played time and the game calendar when both are usable, so **Time in scene** can read past the threshold while the nudge still holds for the game clock - that's normal. Even with no notification, the menu always shows the current scene and how long you have been in it.

### Stop Scene didn't clear the scene

A stop has never once failed to take in 10+ years of un-sticking saves; first with rough one-off versions and now with this. So if it ever reports that the scene didn't end, you've either found a bug in the mod, or something genuinely new. That's exciting. Surprise is where learning happens. A complete log is the best shot at running it down. Turn on Papyrus logging, set diagnostics log to **Every check**, and switch on every log or debug option you can find across your load order, so that if it happens again, it's captured. Then send the complete `Papyrus.0.log` as a bug report. Reload from before it stuck to keep playing in the meantime.

### Filing a bug report, or asking for help

For a bug, set diagnostics log to **Events**, reproduce the problem, then quit. With Papyrus logging on (the `Skyrim.ini` lines are under Settings), open `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` and search for `fth_IJW`. Include that, the scene's form ID and owning quest, and what you were doing when it stuck.

Where to send it:

- **Bug reports:** the [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) on the mod page, or [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Questions and general help:** the [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) on the mod page.

---

## Uninstall

**Remove it for good:**

1. On the Settings page, turn enabled off.
2. Save, quit to desktop.
3. Remove the mod in your manager (or by hand).

Safe to remove mid-playthrough. Skyrim may leave a small inert script stub in the save, like other scripted mods; the game ignores it. Optional: a save cleaner (e.g. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) can clear stubs after removal - use cleaners carefully, on what you intend to remove. You can leave this mod installed while cleaning junk from *other* mods.
