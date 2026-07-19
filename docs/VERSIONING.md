# Versioning

It Just Works uses [Semantic Versioning 2.0.0](https://semver.org/):
`MAJOR.MINOR.PATCH`. SemVer is written for libraries with a code API; a mod's public
surface is different, so this is what the three numbers actually mean here.

## The surface a version speaks to

Internal script guts can change freely between any two releases. What a version
promises about:

- **Save compatibility** - whether updating is safe on a live save. This is the one
  that matters most.
- **Plugin records and FormIDs** - what patches and dependent mods bind to.
- **The callable contract** - Papyrus functions other mods might call, and the MCM
  setting keys (`key:Section`) that persist on disk.

## What each number means

- **PATCH** (the third number) - backward-compatible fixes. Always safe to update on
  a live save.
- **MINOR** (the second) - new features, backward-compatible. Safe to add to a live
  save; nothing you relied on changes.
- **MAJOR** (the first) - a change to the surface above: a record or function others
  depend on is renamed or removed, settings change incompatibly, or - the big one -
  the update is not safe on an existing save and wants a clean one. A MAJOR bump is
  the "read the upgrade notes first" signal.

The save-safety line is the heart of it. **Within a single MAJOR, updating is always save-safe.** MAJOR is the only place we would ever ask you to start clean - and per the [design principles](../DESIGN.md), the whole mod is built so we never have to.

## Before 1.0.0

`0.y.z` releases are public and supported - install them, depend on them. Here SemVer and this mod part ways on purpose. SemVer says `0.y.z` "may change at any time"; we hold one thing firmer than that: **save safety.** We won't ship a 0.x release that breaks an existing save. That contract isn't gated on reaching 1.0 - not breaking your save is a design principle, so it applies now. Updating within 0.x is as safe as updating within any release line.

What 0.x *does* mean here is that the core vision isn't finished. The mod un-sticks scenes today; other things are still to come. **1.0.0 is where that vision is feature-complete** - the switches it was built to un-stick all shipped - and the point the whole contract becomes a formal, lasting promise. Until then, MINOR carries features and PATCH carries fixes, as above.

## Mechanics

`VERSION` is the single source of truth. The top heading in `CHANGELOG.md` must match
it, or the build gate fails.
