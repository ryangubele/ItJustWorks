# It Just Works™

### A debug menu for a game that doesn't need one.

*With gratitude to our friend Todd Howard, without whose inspiration this mod would be unnecessary.*

---

## You have almost certainly hit this and never known

Here is a bug in Skyrim. It's as old as the game itself. It has survived every re-release, remaster, and anniversary edition they've sold you. Hardly anyone talks about it, and it has quietly ended more playthroughs than you'd believe:

**Get stuck in a scene** - a conversation, a cutscene, a little scripted moment - and it can silently stop *later* scenes from ever playing. No error. No crash. Sometimes no symptom at all. Just a quest, hours later, that won't advance, and an internet full of people telling you your save is corrupted and to start a new game.

Sometimes, it is. Sometimes, it's one scene that never got told to stop. That's a four-second fix - *if you know it exists.* Almost nobody does.

Which is the actual game, isn't it? Everyone argues stealth archer versus spellsword, but the real meta was never the build: it's *keeping the save alive long enough to enjoy one.* Making Skyrim work is the sport; Skyrim is the trophy. And you cannot win a game you didn't know you were playing, with rules nobody told you, using tools nobody gave you.

So here's a rule nobody told you, and a tool for it.

Skyrim is a machine full of switches, and it flips them on you all day - you're in a scene, your controls lock, your camera's yanked, an NPC takes the wheel. Every one is supposed to flip back when the moment ends. Every one, now and then, doesn't. That's where this mod lives: **the switch that got stuck.** Not crashes, not vanilla bugs, not save bloat - good mods exist for those, and you should run them. This one's for the specific, maddening, near-invisible thing where the game gets stuck and won't let go.

It's a debug menu. It's a watchdog. It's a shovel to dig yourself out, if you can.

Stuck scenes are where it starts, not where it ends.

---

## What's actually going wrong

It's dumber than you'd hope. **An actor can only be in one scene at a time.** Get quietly stuck in one, and the next scene that needs you can't start. The game has one chair. Someone is still sitting in it.

What happens then? It waits. Or it doesn't. Or it skips the whole thing. Or the quest limps on without it. Nobody can tell you which, because the answer genuinely isn't defined. It hangs on whatever some dev wired up in 2011 and never looked at again:

| The Quest | You Get | Reads As |
|---|---|---|
| Doesn't need the scene to finish | The animation's skipped, you carry on, nothing's broken | "Huh, weird" |
| Can't move until the scene finishes | The NPC waits to cast on you; his cue never comes, so he never does | Can't progress |
| Waits on the scene, but its finish line fires anyway | The quest ticks *complete* - a step inside it never ran | You didn't notice it was broken |
| Needs a thing the scene *did* | A dead end nothing will ever clear | Todd Howard |

Every row looks identical from where you're standing: **an animation didn't play**. Top row costs you nothing. Bottom row costs you the questline. There's usually no way to tell them apart - and if the quest's new to you, the game may never hint a scene was even due. It just moves on, sometimes. Or doesn't. Sometimes the quest even *finishes*, ticked off and done, with one of its own scenes frozen the whole time.

### Reloading won't save you

A stuck scene is saved into your game. It isn't a glitch you can reload away - the game is faithfully restoring a scene that really was running when you saved. So the reload that fixes everything else does nothing, which is exactly why "your save's corrupted" sounds so convincing. Sometimes it's even true. But sometimes it's this, and this takes four seconds.

### It comes for the saves you'd miss

A level-5 vanilla character will probably never see this. A hundred-hour, level-80, five-hundred-plugin save is where it lives - more scripts, more scenes, more happening at once, more chances for two things to go wrong together. A tax on getting attached, collected at the worst possible moment for a reason you can't see. Congratulations for caring.

---

## What you actually do about it

**It watches.** Every 30 seconds - tunable, or off - it checks what scene you're in. Sit in one too long (3 minutes by default) and it says so:

> *In a scene ~3m; blocking others.*
> *See? It Just Works!*

You never have to remember to check, which is the entire point, because you were never going to.

**And there's a menu**, for when you already smell smoke:

- What scene you're in, and which quest owns it
- Roughly how long you've been in it
- The last ten scenes you passed through
- **Stop Scene** - ends the scene you're stuck in
- A hotkey that just names your current scene, for the menu-averse

Why *roughly*? It checks every half-minute, so it knows when you got stuck to within about that. It could give you a stopwatch, but if you've been stuck for two hours and haven't noticed, a stopwatch was never the missing piece.

The missing piece is a button. It was always a button. It will always be a button.

Here's a button.

---

## Where this is going

Debug *menu*. Scenes are the first thing it does, not the last.

The pattern, once you see it, is everywhere: Skyrim is constantly flipping switches on you - you're in a scene, your controls are locked for an animation, your camera's been forced - and every one of those switches occasionally sticks in a position it should have left. Same fix every time: find the stuck switch, flip it back.

**Next up, the player lockouts** - the invisible toggles that freeze your inputs so a scripted moment looks like a scripted moment. They get stuck too, and then you're standing there unable to move, open a menu, or draw a weapon, wondering what you did. Unlike scenes, the game will actually *tell you* which switches are flipped, so this one's a proper diagnosis: here's exactly what's locked, here's the button, done.

After that, whatever else I catch the game leaving switched on when it shouldn't.

**Maybe, a browser for quest stages**, because the console technically already lets you inspect and fix them - it's just so miserable to use that everyone alt-tabs to a wiki instead, which isn't much better. A quest broke on me once; the wiki gave me a console command that swept it off my journal and handed me nothing; I spent an afternoon with a decompiler and a rising blood pressure prying out the step that *actually* finishes it; I marched off to correct the wiki, triumphant, a man with tablets. The answer was two paragraphs down. Had been the whole time. A decent menu would've saved me the afternoon and most of my dignity. Never again.

### What it will never do

- **Tank your performance.** Or try like hell not to. Every release is tuned to be *unnoticeable* on a moderate machine with a moderate load order - and if a feature can't clear that bar, it doesn't ship. It's a big part of why the quest browser is only a *maybe*: something that has to crawl every quest in your game is exactly the kind of thing that isn't free, and free is the price of entry.
- **Kill your save.** Not on purpose, anyway - and every design choice bends away from it. Safe to add mid-playthrough, safe to remove, self-healing across reloads. It holds nothing of the world, latches onto nothing, and cleans up after itself. Every scripted mod carries some risk; this one is built to minimize it.
- **Let you do something risky without a warning.** When an operation can cost you something, it'll tell you first.
- **Break quietly.** If the mod itself is the one misbehaving, it tries to help you catch it, not hide it - a Papyrus log you can switch on, a nudge when a dependency's set up wrong, a readout of exactly what it's seeing. Better it point at its own faults than leave you guessing.
- **Fix Skyrim.** I can't. Nobody can. USSEP - the patch in every serious load order, the one that's quietly fixed thousands of this game's sins - ran into a quest you can break just by *picking a locked door* instead of finding the key. Their fix wasn't to work out why a lockpick detonates it. They made the door need the key.

  That's not surrender. That's the job, and it's ours too, from the far end. **Different bugs, same creed:** USSEP keeps you from falling in; this lets you know you're in a hole anyway. Nobody fixes the root, because nobody fixes Skyrim - the job is just to try to keep the save alive. So this mod doesn't argue with the game: It watches. It warns you. It hands you a shovel.

  After all, anything more would defeat Todd's vision.

---

## Is there a console command for this?

Maybe. Genuinely, I have no idea.

Try `player.cf "ObjectReference.GetCurrentScene"`. It might work. It might not. It might depend on your version, or on some mod you've got quietly bridging it. I could do this once. Then I couldn't. So I wrote a mod and never tried again. Nobody knows why. Now it doesn't matter.

Either way, you'd have to *think to type it* - and you won't, because you don't know you're stuck. Which is what this mod is for.

### The game ships a cure. It uses it basically once.

Skyrim has a built-in fix for exactly this. It's a function called `ForceStart`, and it does the obvious brutal thing - barges into a scene and evicts whoever's stuck, no questions asked. Across the entire vanilla game it gets called exactly twenty-four times, and every single one is the same quest: the peace summit where you sit the Empire and the Stormcloaks down at one table.

They were probably right to ration it. `ForceStart` doesn't check whether the scene it's evicting is actually stuck - it just evicts it. Reach for it everywhere and you'd be breaking working scenes to start ones that might get jammed, trading this bug for its mirror. Instead of a scene that won't start, you can't trust any scene to finish. So the sledgehammer stays in the one room where every variable was nailed down, and nowhere else. Exactly why, everywhere else, you're on your own. This mod is the version you can reach without ending a war.

---

## Requirements

- **SKSE64**
- **MCM Helper**
- **powerofthree's Papyrus Extender**
- **powerofthree's Tweaks**, with `Load EditorIDs = true` set in `po3_Tweaks.ini`

That last dependency is soft but strongly recommended. Without it, scenes show up as bare ID numbers instead of names, and you want the names. The mod will say so, once, if it notices.

ESL-flagged, so it costs you no load-order slot. Safe to add mid-playthrough. Safe to remove. It's a watchdog; it holds nothing.

---

## Languages

The menu ships in English, with machine-translations for Simplified Chinese, Czech, French, German, Italian, Japanese, Polish, Russian, and Spanish. Pick the ones you want in the installer - corrections are always welcome.

One quirk worth knowing: Skyrim loads the menu translation that matches your game's **language setting**. So if your game runs in English but you want the menu in another language, it keeps reading the English file - and the menu stays English even though the translation is installed. Two ways around it: in the installer, set that language as your **default menu language** (it writes the translation over the English file for you); or by hand, in the mod's `Interface\Translations\` folder, rename your language's file - `fth_ItJustWorks_<LANGUAGE>.txt` - to `fth_ItJustWorks_ENGLISH.txt`, replacing the English one.

---

## The rest of the toolkit

This mod does one thing: the stuck switch. It deliberately doesn't do the rest, because better mods already do. Keeping a save alive is a team sport. If you're serious about it, run these too:

- **USSEP** - prevention. Fixes thousands of bugs before they ever bite.
- **SSE Engine Fixes** and **Bug Fixes SSE** - the engine-level papercuts most people never diagnose.
- **Crash Logger** - so a crash tells you *what*, not just *that*.
- **ReSaver (FallrimTools)** - cleans script gunk out of a save. Powerful, and a genuine footgun; know what you're doing before you point it at a save you love.

### Kindred spirits

Not requirements - just proof you're not imagining it.

- **Reset Random Dialogue Scenes** - someone else who noticed scenes stick, and built a quiet weekly reset for one flavor of it. They're not sure it's a bug. We're sure it is, but not what to call it. That *is* the story.
- **Debug Menu - Navmesh Viewer** - another debug menu for a game that doesn't need one. Kindred by the name alone. There's a whole family of us out here, building tools for problems that officially don't exist.

---

## Why this exists

I lost a quest reward to this once, or at least I thought I did. I chased it to genuinely stupid places and never got it, but in the process, discovered a stuck scene was what was breaking so much of the rest of my game. Years later, knowing the game far better, I took that quest completely apart, and I still can't tell you for certain what happened. If that's the price of understanding *one* broken quest, nobody at their desk at midnight stands a chance.

It's a backup, too. This is the third time I've written this thing, and the first two are gone - not through carelessness, exactly. Each one I threw together in a hurry to climb out of a hole and get back to *playing the game*, which is the entire point of the exercise. I kept choosing the game over the meta, so the tool stayed hasty garbage I never thought worth saving. So I didn't. And it's gone. Twice.

For years, I never saw anyone name it - only the symptoms: people with the obvious signs, losing saves they loved, told the same thing every time, that it was corrupted, start over. Lately there's a little murmur - a fly-by post here and there telling someone to check whether their character's stuck in a scene, then nothing after. No name. No fix. No follow-up. For a long time it honestly felt like I was the only one who'd tied it together.

No more. This one's built to keep and built to share, because the fix turned out to matter more than any single afternoon it dug me out of. There's no better backup than other people having a copy - so this time, we win the meta together.

Call it penance, too - for every save I could have spared with what I knew, and couldn't, because I had no tool to hand anyone. Which is, I'm aware, a tremendous amount of gravity for a game about shouting at dragons. I've decided to allow it.

---

## One thing I'm not claiming

Let me be careful, though: that feeling was never the truth. I didn't discover this, and I'm not the one who cracked it. Everyone who ever brushed this same wall was as stranded as I was - a few had even half-named it - and not one of us had a thing worth handing the next person. Being first to a locked door you can't open isn't discovering anything.

I'd built my own fix, and it was never any good. It was only after all that - only after I turned a small army of AI research agents loose on the whole modding internet, hunting for something else - that I tripped over a single mod that patches even a sliver of this. By accident.

One mod. Thirteen years. That's buried. Archaeological, almost. Somewhere under a sedimentary layer of "my save is corrupted" threads lies a truth with no name and no search terms.

My favorite thing I found while writing this is a single line, in the last place anyone would look. The Creation Kit wiki, on the reference page for a function called `IsPlaying`:

> *"Even though a scene is stuck, it is still playing, and thus this function
> will return true. Therefore it is not entirely useful for debugging a scene."*

*"Even though a scene is stuck"* - dropped in like everyone knows. Someone did. Someone knew well enough to warn the next modder off the obvious tool. And they left the note buried on the API page for a boolean, on a wiki built for people making mods, not playing them. To ever read it, you'd have to already suspect scenes, already know that function exists, and already be neck-deep in the scripting docs.

That's the whole thing in one link. The knowledge isn't missing - it's just nowhere you can reach it, in words you'd think to search. You can quietly suspect a bug that has no name to look up...

So that's the mod. A thing that's hard to find out, made easy - before it costs you the save.

Eventually, with a little luck, a power tool in the community's kit to help *you* win the meta.

---

**Ryan Gubele** - MPL-2.0, source in [the repository](https://github.com/ryangubele/ItJustWorks).

Thanks to the MCM Helper and powerofthree teams, whose work this is built on. And to the authors of the rest of the toolkit up there - USSEP, ReSaver, the engine fixers and the others - because keeping a save alive is a team sport. To Todd and Bethesda: for a genuine and enduring masterpiece; and for the inspiration.
