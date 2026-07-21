# Quest repair

Not a quest browser, and not a stage editor. A **repair tool** for the specific, already-diagnosed quests the community knows how to break and knows how to fix - it carries the answers with it instead of computing them live. That single shift is what gets past the wall a general browser never could.

**Serves, in shape:** *Never break a save*, *Cost nothing you'd notice*, *Do one thing well*, *Respect the player*, *Make it observable* - shipping the knowledge instead of deriving it is what *could* get a quest tool past the wall a browser hit. But a shape that's right on paper isn't the same as one that's buildable: the runtime data path is genuinely unproven, and the database's construction and upkeep are unsettled. It stays named-for-itself until that feasibility work is done - a version target waits on it.

## The shape

Ship a curated **database** of quests known to break: quest IDs, the stages known to jam, and the stage(s) the community believes are safe to advance to. Human-readable and human-editable - JSON or XML, whatever the game reads easily and a person can still hand-edit a fix into. It's mined once, offline, ahead of release, so the expensive part never touches a player's frame budget.

In the MCM, a **Quests** page: blank but for one button. Press it and - after a single line warning that it'll hitch the game for a moment, to accept or decline - it scans the journal for *uncompleted* quests. That set is already small: you have to have started a quest and not finished it. Then it shrinks again the instant it meets the database - any quest with no known-broken stage is dropped before it is ever shown. What's left is the short list of things that might genuinely be stuck, each with the community's known-good nudge already attached.

## How it clears the three bars

The general browser stayed an idea because it couldn't answer three questions inside the principles. Shipping the knowledge instead of deriving it is how this design *aims* to answer them - on paper. Each answer still assumes the runtime piece is buildable at all, which isn't proven (see Open questions).

**Safe.** The mod never breaks a save on its own - that principle holds here unchanged: read-on-demand, in-memory, no persistent state, nothing latched onto the world. What a *player* does with the tool is their call. It hands them a shovel to dig out of a stuck quest; if someone would rather dig themselves into a hole with it, nothing short of not building the shovel would stop them, and respecting the player means not pretending otherwise. What respect *does* ask is that we help them avoid it by accident - and the design guards accidents two ways:

- **It only offers known repairs.** A quest the database doesn't recognize never appears, and each skip it does offer is one the community already believes is safe for a documented break - never a raw stage-setter pointed at arbitrary quest logic. The curated set is where an accidental misfire could live, so that's where the guardrail sits. (A side effect, not the aim: this also makes it a poor tool for skipping a *working* quest - anyone set on that has the console. It just won't invent a fix it doesn't have.)
- **It leans on the reload.** Setting a stage is heavier than ending a scene, but it isn't irreparable - it's only committed from the moment of the click. Recommend a save first, or better, trigger one reliably before applying, and a skip that goes wrong costs a reload, not progress: the loss window is pre-click-save to click, which is nothing.

The database mines solid quest IDs and stages, but *which* stage is safe to advance to is community lore - and that's an acceptable source. It's mostly right; the rare misses are quests broken in ways nobody has fully untangled (Frostflow is the standing example). Whatever errors ship in a given revision get corrected the ordinary way, through feedback and bug reports, with the save-first habit as the backstop for when the data is wrong. Curation quality is the real ongoing work.

**Observable.** The database *is* the observability. Every offered skip arrives with why the quest is flagged and what the target stage does, so the tool can show its reasoning before it acts - drawn from real community data, not a guess about opaque engine state. "Here is the known break, here is the stage people report clears it, here is exactly what that will set" is legible in a way live quest-crawling never was.

**Performant.** Nothing polls, nothing crawls the full quest list. The heavy mining happens offline and ships as data. The only runtime cost is one opt-in, warned scan of the small uncompleted-journal set against an in-memory lookup - and then it's gone.

## It stays out of the save

Read the database into memory only while the player is on the page; discard it on exit. No world state, no aliases, no persistent footprint - the same save-safety the watchdog already lives by. Re-entering the page just scans again, which is cheap and, in practice, rare: if a stage was bugged and the nudge fixed it, they aren't going back to it.

## Community and mod-author integration, close to free

Give integrators a namespaced folder and a documented format, then read and parse whatever lands there. Two audiences fall out of one design:

- **Players** get a repair database that grows as the community feeds it.
- **Mod authors** get a development tool. They ship their own "possibly broken" stage data beside their mod - blind-installed into the folder, or offered through the FOMOD - and use the same page to bypass the rough spots in their own quests while they're still building them.

The repair tool for players is the debugging harness for authors: same code, same data format, two reasons to keep it installed.

## Open questions (feasibility)

The shape is promising; whether the engine cooperates is not yet known. This is real research, not detail work.

- **Can Papyrus read the external database at runtime at all?** The evidence cuts both ways. Many authors bake their JSON straight into the co-save, which hints at a genuine limitation - yet some mods appear to read external data at runtime, or something close to it. The mod already ships PapyrusUtil (StorageUtil); JsonUtil, JContainers, and whatever mechanism MCM Helper uses to read its own `config.json` are all leads worth testing - none of them a proven answer yet. If a live external read turns out impossible, the fallback is baking the data in, which trades away the "stays out of the save" property and would have to be weighed against it.
- **How much can live in memory, and how is it parsed?** The in-memory-only story assumes the database is cheap to load and hold for a session; that needs measuring against a realistically sized dataset, not assumed.
- **What does the journal scan actually cost, and what API surface does it need?** "Scan the uncompleted quests" is easy to say; the real per-call cost and its reliability across large load orders have to be pinned down.

Proper scope and a sensible design don't remove these - they make the odds of clearing them far better than a general browser ever had.

## Prior art

Research (2026) found no clean, maintained, standalone quest-stage editor - MCM Cheat Menu carries the feature but is an unmaintained, broad cheat menu. This is a different thing regardless: not an editor but a curated-repair database with a scanner in front of it. Re-check before building; if a good fit exists, recommend it instead.
