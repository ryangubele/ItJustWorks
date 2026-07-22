# Using It Just Works™

## What it does, and why

Skyrim runs on *scenes* - scripted moments like conversations and cutscenes that are meant to end on their own. Sometimes one doesn't, and a stuck scene can silently block the ones that come after it, quietly breaking a quest or even a whole save with no error to warn you. This mod watches the scene you're in and alerts you if you've been stuck in one too long, shows you what you're in from a menu, and lets you stop a scene that's jammed. That's the whole idea: catch the stuck switch before it costs you the save.

Everything the mod does, you drive from one page: **Mod Configuration Menu > It Just Works**. This is what each part of it does.

The short version, if you just installed it: leave the defaults alone, keep playing, and let the watchdog tap you on the shoulder if you ever sit in one scene too long. Everything below is for when you want to look closer.

## Seeing the menu in another language

The mod ships menu translations for several languages - pick them in the installer. Skyrim loads the translation that matches your game's **language setting**, so if your game runs in English but you want the menu in another language, it keeps reading the English file and the menu stays English even though the translation is installed. Two fixes: in the installer, **tick that language in the first step, then choose it as your default menu language in the second** (it writes the translation over the English file for you, and keeps an English `.bak` you can rename back); or by hand, rename your language's file in `Interface\Translations\` - `fth_ItJustWorks_<LANGUAGE>.txt` - to `fth_ItJustWorks_ENGLISH.txt`, replacing the English one.

## Current scene

The top of the page is a live readout of the scene you're in right now, or "None" if you aren't in one. Opening the page takes a fresh reading, so it's never stale.

- **Scene** - the scene you're currently in, by name (its Editor ID) when names are available, or a raw ID number when they aren't (see the light below).
- **Form ID** - the scene's raw ID number, always shown, in case you need it for the console or a bug report.
- **Owning quest** - the quest that scene belongs to. Usually the more useful name: it tells you *what* is holding you.
- **Time in scene** - roughly how long you've been in this scene *this session*. Marked with a `~` because the mod checks on a timer, so it knows the answer to within one check. The clock is real-world time for the current game launch only: **a reload restarts it from zero**. After a reload, continuous play past the warn threshold still gets an alert; short reload-loops that never stay in-game long enough will not add up prior sessions' time.

## The "Editor IDs loaded" light

A status light, not a switch - clicking it does nothing but flip it back to the truth.

- **Lit** - good. powerofthree's Tweaks is loading Editor IDs, so scenes and quests read as names.
- **Dark** - names are off; everything shows as ID numbers instead. The mod works exactly the same either way - it's just harder to read.

To turn names on: open `po3_Tweaks.ini` (in your powerofthree's Tweaks install) and set `Load EditorIDs = true`, then restart Skyrim. The light comes on and the names appear.

The mod also says this once, on its own, the first time it notices names are off. This light is the permanent version of that notice - the thing to point at in a help thread when someone asks why their scenes are all numbers.

## Actions

- **Stop Scene** - the fix. If you're genuinely stuck, this ends the scene you're in. It's deliberately two steps: press **Stop Scene** once to arm it (a line appears confirming it will stop when you close the menu), and press it again to cancel. The stop itself happens the moment you close the menu, because that's the only point the game is running enough for it to take. So: arm it, close the menu, done.

  Only reach for this if you believe the scene is stuck. Stopping a scene that's working normally can break things, and stopping a stuck one can set off a short burst of delayed events as the game catches up - that's expected, not a new bug.

- **Refresh** - takes a fresh reading of the current scene right now, without closing and reopening the page.

## Recent scenes

The last ten scenes you passed through, newest first, each with roughly how long it lasted. Useful for "wait, what was that thing I was just in," especially when a scene flickers past too fast to catch.

## Watchdog

The part that watches so you don't have to.

- **Warn me after** - how many minutes in a single scene before the mod alerts you. Default is 3. Set it to 0 to never warn.
- **Check every** - how often the watchdog looks, in seconds. Default is 30. Set it to 0 to switch the watchdog off entirely. This is meant to catch the you-got-stuck-a-while-ago case, so it doesn't need to be fast: anywhere from 10 to 240 seconds is plenty, and lighter on your game.

When the watchdog fires, it's two short lines in the corner - how long you've been in the scene and that it's blocking others, then the mod's name. You don't have to have the menu open to see it.

## Watching it work (the Diagnostics page)

- **Watchdog** - one word for whether the background check is running right now: **Running**, **Waking up** (normal for a moment right after a reload), **Late** (still alive but a check came in slower than its interval - usually a sign of heavy script load), **Off** (you set Check every to 0), or **Dormant** (turned off on the Uninstall page). It's how you confirm the mod is alive without opening a log.
- **Last self-repair** - the mod quietly re-syncs its own state now and then, most often right after a reload - for instance, re-syncing the scene timer so a scene you were stuck in across a reload can still alert after a full threshold of continuous play *this session*. That re-sync **restarts** the stuck clock from the reload; it does not add time from before the load. A line here is normal, healthy housekeeping (the tool telling you it fixed itself), not a fault.
- **Diagnostics log** - how much the mod writes to the Papyrus log, for troubleshooting or a bug report:
  - **Off** - nothing. The default; leave it here for normal play.
  - **Events** - scene changes, alerts, and every time the mod corrects itself. Set this to file a bug.
  - **Every check** - adds a line every poll (the loop's heartbeat, the timer climbing). For chasing a timing issue, then set it back.

The log only reaches disk if Papyrus logging is switched on in the game. Add a `[Papyrus]` block to `Skyrim.ini` (or `SkyrimCustom.ini`) in `Documents\My Games\Skyrim Special Edition\`:

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Restart Skyrim. The file lands at `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`; search it for `fth_IJW` (`findstr fth_IJW Papyrus.0.log`, or `grep`). With Mod Organizer 2 that's your real Documents folder, not the virtual game folder.

## Settings

- **Name current scene** - bind a key here, and pressing it pops up the name of whatever scene you're currently in, without opening the menu at all. The fastest "what am I in right now."
- **Clear hotkey** - unbinds that key. There's no ESC-to-clear here (in this menu ESC is Pause, and the game warns you about the conflict), so this button is how you take the binding back off once you've set one.

## About

The version, so you can tell at a glance which build you're running - handy when you're asking for help or checking whether you're up to date.

## Turning it off, or removing it

You don't have to uninstall to make the mod stop. The **Uninstall** page has one **Enabled** switch: turn it off and the mod goes dormant - the watchdog stops polling and the hotkey unregisters - without cleaning anything or touching your save. Turn it back on whenever you like and it picks up exactly where it left off. That's the gentle way to shelve it mid-playthrough, and an easy way to check whether it was ever the thing bothering you.

If you do want it gone for good, remove it in this order:

1. **Turn it off** on the Uninstall page.
2. **Save, then quit** to the desktop.
3. **Remove the mod** in your mod manager (Vortex, MO2, or by hand).

That's genuinely all that's required. Nothing this mod does will break a save on the way out - it holds no game objects hostage, it blocks nothing, and nothing else depends on it. What it leaves behind is what *every* scripted mod leaves behind: a small, inert stub in the save where its script used to live. Skyrim ignores it. If you'd like even that gone, you can sweep the stub out with a save cleaner once the mod's removed.

### About save cleaners (ReSaver)

On a long save you'll run a cleaner now and then - **ReSaver** (part of FallrimTools) is the usual one - to clear script gunk left by *other* mods you've swapped or removed. You can leave It Just Works installed while you do. It's built to survive a clean: alias-free, no world state, self-healing. A normal pass won't touch it, and even an aggressive one that clears its poll timer or hotkey, it re-arms the next time you open the menu. The risk to *this* mod is about as low as a scripted mod gets, by design.

The cautions that remain are about the tool, not us: know what ReSaver does before you point it at a save you love, and target what you actually removed rather than a blind sweep.
