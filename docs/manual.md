# Using It Just Works™

## What it does

Skyrim uses *scenes* for conversations, cutscenes, and other scripted moments. Sometimes a scene never ends. That can quietly block later scenes - a quest that won't move, no error, no crash. This mod watches the scene you're in, warns you if you've been in one too long, shows you what it is, and lets you stop it if it's stuck.

**Short version:** leave the defaults on, keep playing. If you get an alert, open **Mod Configuration Menu > It Just Works**.

Needs **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)**, and **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (with `Load EditorIDs = true` if you want names instead of ID numbers). Install notes are on the [mod page](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Five pages: **Scene**, **Watchdog**, **Settings**, **Diagnostics**, **Uninstall**.

---

## Scene

### What you're in

Live readout of the current scene, or **None**. Open the menu for a fresh reading.

- **Time in scene** - the line that usually matters here: roughly how long you've been in it this session (`~` means approximate). That's the stuck-or-not signal. **Reloading the game resets this timer.** A long stretch of continuous play after a reload can still warn you; bouncing through reloads without staying in-game long enough will not.
- **Scene** - name when names are available; otherwise an ID number (see Editor IDs on Diagnostics).
- **Form ID** - the raw ID, always shown. Handy for the console or a bug report; you don't need it to stop the scene - that's the button below.
- **Owning quest** - which quest that scene belongs to, when you want the wider context.

### Stop Scene

If you believe the scene is stuck, this ends it.

1. Press **Stop Scene** once - a line confirms it's armed.
2. Press again to cancel, or **close the menu** to stop. The stop runs when the menu closes.

Only stop a scene you think is stuck. Stopping a normal one can break things. Stopping a stuck one can fire a short burst of delayed events as the game catches up - expected, not a new problem.

**Refresh** re-reads the current scene without closing the menu. Opening already takes a fresh reading; use this if you've had the menu open a while and want an update - especially with mods like [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859) that keep the game running while menus are open.

### Recent scenes

Last ten scenes, newest first, with rough duration. Same kind of approximate time as above (reload doesn't keep a stopwatch of earlier sessions).

---

## Watchdog

Watches so you don't have to.

- **Warn me after** - minutes in one scene before an alert. Default **3**. **0** = never warn.
- **Check every** - seconds between checks. Default **30**. **0** = turn the watchdog off.

Alert is two lines in the corner, for example:

> scene blocking others ~3m  
> See? It Just Works!

Once per scene until you leave it or the scene changes. Missed the toast? Open the menu - the readout still shows what you're in and for how long. The mod does not stop the scene for you; that's **Stop Scene**.

---

## Settings

- **Enabled** - on by default. Turn it off to shelve the mod without uninstalling. The watchdog and hotkey stop; turn it back on later and it resumes. Your save is fine.
- **Name current scene** - bind a key; press it to see the current scene name without opening the menu.
- **Clear hotkey** - removes the binding. ESC won't clear it here (ESC is Pause in this menu).
- **Diagnostics log** - how much goes to the Papyrus log. Leave **Off** for normal play. Use **Events** when filing a bug; **Every check** only if you're chasing a timing issue, then turn it back.

  Logging only works if the game is writing Papyrus logs. In `Documents\My Games\Skyrim Special Edition\`, edit `Skyrim.ini` or `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restart. Log file: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Search for `fth_IJW`.

---

## Diagnostics

- **Editor IDs loaded** - status light, not a switch (clicking it snaps back).
  - **Lit** - names are on.
  - **Dark** - you'll see ID numbers; the mod still works.

  Names on: in `po3_Tweaks.ini`, set `Load EditorIDs = true`, restart Skyrim. The mod also says this once the first time it notices names are off.

- **Watchdog** - whether the background check is up:
  - **Running** - fine
  - **Waking up** - normal right after a reload
  - **Late** - still working, but checks are slower than usual (busy game)
  - **Off** - you set Check every to 0
  - **Dormant** - Enabled is off on Settings

- **Last self-repair** - the mod sometimes fixes its own bookkeeping (often after a reload). A line here is normal. Not a fault, not something you need to clear.

- **Version** - build number, for help threads and updates.

---

## Uninstall

**Remove it for good:**

1. On the **Settings** page, turn **Enabled** off.
2. Save, quit to desktop.
3. Remove the mod in your manager (or by hand).

Safe to remove mid-playthrough. Skyrim may leave a small inert script stub in the save, like other scripted mods; the game ignores it. Optional: a save cleaner (e.g. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) can clear stubs after removal - use cleaners carefully, on what you meant to remove. You can leave this mod installed while cleaning junk from *other* mods.

---

## Seeing the menu in another language

The mod ships menu translations - pick them in the installer. Skyrim loads the file that matches the game's **language setting**. English game + another language installed still reads the English menu file unless you override it.

**Installer:** tick the language in step 1, then set it as default menu language in step 2 (writes over the English file; keeps an English `.bak`).

**By hand:** rename `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` to `fth_ItJustWorks_ENGLISH.txt` (replace the English file).
