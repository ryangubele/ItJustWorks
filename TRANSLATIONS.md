# Translations

It Just Works™ ships its in-game menu (the MCM) and manual in ten languages.

## Important: everything but English was machine-translated

The English is written by the author. **Every other language was translated by an AI (a large language model), not by a native speaker.** The translations are careful and technically consistent - filenames, settings, and terms like `Editor ID`, `Form ID`, and `Papyrus` are deliberately left untranslated so you can still cross-reference them - but no fluent human has reviewed them.

If you speak one of these languages and something reads wrong, stiff, or plain incorrect: **please improve it.** That's the entire point of open source and a shareable license. Open a pull request, or send corrections however suits you - the credit is yours, and the gratitude is guaranteed. A native pass is the one thing a machine can't give this, and it's welcome for every language, including English.

You don't have to be fluent to help, either. If a line in the menu looks **cut off** or spills past the edge of the panel - likeliest in Chinese or Japanese, where the characters are wider - that's a genuinely useful report, and an easy one to send: a screenshot and the language is enough. The menu column is narrow, so the occasional too-long line is a display fit to trim, not a broken translation.

## What's translated, and the one thing that isn't

- **The MCM menu** - fully translated: every option label, every help description, and the dynamic status strings the scripts push into the menu (Stop arm/cancel hints, watchdog state, last self-repair phrases).
- **The manual** (`docs/manual.<lang>.md`) - fully translated.
- **The in-game pop-up notifications are still English.** The watchdog alert, the one-time "names are off" notice, and the Stop-result messages are printed straight from the script (Papyrus `Debug.Notification`), which - unlike the MCM - has no built-in way to look up a translated string. So a German player gets a fully German menu but still sees those brief corner messages in English.

  If you know a clean way to localize `Debug.Notification` output in Papyrus - a per-language string table the script can read at runtime, for instance - that fix is wanted. It's the last English-only corner of the mod.

## Languages

The ten Skyrim languages, by their in-game names:

- English (`ENGLISH`) - source
- Chinese, Simplified (`CHINESE`)
- Czech (`CZECH`)
- French (`FRENCH`)
- German (`GERMAN`)
- Italian (`ITALIAN`)
- Japanese (`JAPANESE`)
- Polish (`POLISH`)
- Russian (`RUSSIAN`)
- Spanish (`SPANISH`)

MCM Helper selects the matching menu automatically from your game language. The manuals are linked below.

## Manuals

- [English](docs/manual.md)
- [Chinese / 简体中文](docs/manual.zh.md)
- [Czech / Čeština](docs/manual.cs.md)
- [French / Français](docs/manual.fr.md)
- [German / Deutsch](docs/manual.de.md)
- [Italian / Italiano](docs/manual.it.md)
- [Japanese / 日本語](docs/manual.ja.md)
- [Polish / Polski](docs/manual.pl.md)
- [Russian / Русский](docs/manual.ru.md)
- [Spanish / Español](docs/manual.es.md)
