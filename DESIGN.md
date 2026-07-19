# Design principles

It Just Works™ is a small tool with strong opinions about how it's built and how it behaves. These are the rules it holds itself to. If a change would break one of them, the change doesn't ship.

## Keep it light

It's a video game about shouting at dragons, and this is a mod about the small ways it falls over. The tone is a grin, not a grievance. Every jab is in good fun. The animosity is fake, all of it, because you have to love a thing this broken to spend this long fixing it. The levity isn't decoration - it's in the code, the copy, and everything this touches.

## Do one thing, and do it well

Own one category: the stuck transient states Skyrim leaves switched on when it should have flipped them back. Leave everything else to the mods that already do it well. Keeping a heavily-modded save alive is a team effort, the real meta underneath the build guides, and this is one specialist on that team, not the whole roster. Breadth costs performance and reliability on a game that punishes both; staying narrow is a feature, not a limitation.

## Never be the cause of a broken save

The prime directive. You run this on a save you care about, often a large and fragile one, so it is built to earn that trust: safe to add mid-playthrough, safe to remove, holding nothing of the world, latching onto nothing, cleaning up after itself, and healing across reloads. When an action can cost you something, it warns you before, not after. Every scripted mod carries some risk; this one bends every design choice toward never being that risk.

## Build on modern frameworks and modern habits

The current standard stack, not legacy scaffolding held together by inertia. It costs no load-order slot, and it asks for nothing exotic. If the ecosystem has a modern way to do a thing, that's the way this should do it.

## Follow community standards

Do it the way the community expects it to be done, not the way that's novel. Standard MCM conventions, standard file layout, standard versioning, standard licensing. Anything an experienced modder expects is where they expect it. Personal taste doesn't get to override an established standard unless the flavor is genuinely strong, and it rarely is.

## Keep the source accessible

Open, readable, and available. The complete source lives in the public repository linked from the mod page. Nothing about how this works is a secret - which is the whole point, since secrecy is the exact problem it exists to undo.

## License it to be shared, and to be taken over

MPL-2.0. Built to keep and built to share. Fork it, fix it, or take it over outright - the knowledge this protects has been lost before precisely because no one could hand it to the next person. A copy in someone else's hands is the best backup there is.

## Respect the player. Respect the contributor.

Players deserve a frictionless experience with minimal barriers to entry, and contributors who invest their time deserve genuine recognition and support in return.

## No ego

A better way is a better way, even if it bruises pride or requires extensive changes. If a better tool comes along, leave gracefully and pass the torch.

---

# Practices

The principles above are what we hold to be true; the practices below are what we do about them. A practice isn't a new rule competing with the principles - it's a habit they hand down, the concrete shape a value takes in how the tool actually behaves. It earns its place only by naming the principles it stands on, and it never overrules them. When several of them point the same way, the practice they add up to is worth writing down.

## Make it observable

You should never have to guess whether it worked. Every state that matters and every correction the tool makes is visible somewhere you can reach without a debugger - on the readout while you play, in the log when you're digging. Five principles converge on it:

- **Respect the player** - someone diagnosing odd behavior in a save they care about deserves to see what the tool saw, not a black box.
- **Respect the contributor** - no one should have to spin up a five-hundred-plugin load order sixteen times to confirm a fix because the tool left no trace of what it did. Good logging is the whole difference between one careful reproduction and sixteen frustrated ones.
- **Never be the cause of a broken save** - a fix that guards the prime directive but fires silently can't be verified, and an unverifiable safety fix is only a hope.
- **Build on modern habits** - structured, greppable logging is table stakes for modern software; a tool without it is quietly holding itself to an older, lower standard.
- **No ego** - a tool with no way to watch itself is implicitly claiming it never errs. Instrumentation is the honest opposite: it exists *because* we make mistakes, and it expects to catch them.

So when this does something that matters, it says so. A correction no one can see is a correction no one can trust.

## Cost nothing you'd notice

You're a guest in someone's save - often a huge, fragile one - and a guest doesn't help by making the place run worse. Every release is tuned to be unnoticeable on a moderate machine with a moderate load order, and a feature that can't clear that bar doesn't ship, however useful it would be. This is **Respect the player** made literal: their frame budget and script headroom aren't yours to spend. It leans on **Do one thing, and do it well** to get there, since the surest way to stay cheap is to stay narrow - and it quietly serves **Never be the cause of a broken save**, because script load is one of the stresses a fragile save least needs.