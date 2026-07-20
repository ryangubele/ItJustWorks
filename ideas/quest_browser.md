# Quest browser

The console already lets you inspect and set quest stages; it's just miserable enough that everyone alt-tabs to a wiki instead, which isn't much better. An in-game MCM browser for quest stages - see where a quest actually is, nudge it forward when it's genuinely broken - would be the friendlier tool.

This one's genuinely wanted; it'd ship in a heartbeat if it could clear the bar. Whether it can is the real, open question - about *how* to build it inside the principles, not *whether we want to*.

## It's closer to the mission than it first looks

A quest stage *is* a state, and a stuck or skipped stage *is* that state broken - the same shape of problem as a transient flag Skyrim forgot to flip back, just a deeper and nastier layer of it. So this isn't a clean outsider to "do one thing well"; it's a blurry-edged member of the same family. That matters because it means the reason it stays an idea *isn't* "off-mission" - it's on-mission and still not ready, which is the harder, more honest place to be.

## Why it still has no target

It doesn't have one because we don't yet know how to build it inside the principles - and we haven't proven we can't. Both true, both *yet*. Here's what we're weighing:

- **Can it be made safe?** Poking quest logic can drive a quest into states its author never wired for. Whether a version that only diagnoses and repairs - never a footgun - can be built at all is an open question.
- **Can it be made observable?** Quest logic is some of the least legible state in the engine. Showing *why* it thinks a quest is stuck, and *what* a nudge will do before it does it, is a real design problem, not a `Trace` line.
- **Can it be made performant?** Anything that has to crawl every quest in a load order isn't free, and the *Cost nothing you'd notice* practice is strict: a feature that can't stay unnoticeable doesn't ship.

Answer those three inside the principles and it earns a target. Until then it stays an idea - not rejected, just not yet grounded.

## Prior art

Research (2026) found no clean, maintained, standalone quest-stage editor - MCM Cheat Menu has the feature but is an unmaintained broad cheat menu. Re-check before building; if a good one exists, recommend it instead of rebuilding.
