# Translations

It Just Works™ ships its in-game menu (the MCM) and manual in ten languages.

**Read this page in your language:** [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Important: everything but English was machine-translated

The English is written by the author. **Every other language was translated by an AI (a large language model), not by a native speaker.** The translations are careful and technically consistent - filenames, settings, and terms like `Editor ID`, `Form ID`, and `Papyrus` are deliberately left untranslated so you can still cross-reference them - but no fluent human has reviewed them.

If you speak one of these languages and something reads wrong, stiff, or plain incorrect: **please improve it.** That's the entire point of open source and a shareable license. Open a pull request, or send corrections however suits you - the credit is yours, and the gratitude is guaranteed. A native pass is the one thing a machine can't give this, and it's welcome for every language, including English.

You don't have to be fluent to help, either. If a line in the menu looks **cut off** or spills past the edge of the panel - likeliest in Chinese or Japanese, where the characters are wider - that's a genuinely useful report, and an easy one to send: a screenshot and the language is enough. The menu column is narrow, so the occasional too-long line is a display fit to trim, not a broken translation.

## What's translated

- **The MCM menu** - fully translated: every option label, every help description, and the dynamic status strings the scripts push into the menu (Stop arm/cancel hints, watchdog state, last self-repair phrases).
- **The manual** (`docs/manual.<lang>.md`) - fully translated.
- **The in-game pop-up notifications** - translated. The watchdog alert, the "names are off" notice, the Stop results, and the hotkey readout follow the **Notification language** setting on the MCM's **Settings** page, in all ten languages; the installer seeds it from your menu-language choice.

## What's deliberately English

- **The `See? It Just Works!` sign-off** - the joke is English-native. Taste, not a limitation.
- **The Papyrus diagnostic log** - the optional `[fth_IJW] …` lines the mod writes when you turn logging on stay English on purpose. They're a structured, greppable `key=value` dialect meant to be searched and pasted into a bug report; translating them would break that greppability and fan out into an unmaintainable per-language matrix, for no one's benefit.

## Languages

The **Notification language** setting lists the ten languages by their English names, so the dropdown stays readable whatever font you have. Find yours here (top-to-bottom matches the dropdown order):

| In the menu | Your language | Skyrim code |
|-------------|---------------|-------------|
| English | English | `ENGLISH` |
| French | Français | `FRENCH` |
| German | Deutsch | `GERMAN` |
| Italian | Italiano | `ITALIAN` |
| Spanish | Español | `SPANISH` |
| Polish | Polski | `POLISH` |
| Russian | Русский | `RUSSIAN` |
| Chinese | 简体中文 | `CHINESE` |
| Japanese | 日本語 | `JAPANESE` |
| Czech | Čeština | `CZECH` |

The **menu** language follows your Skyrim game language (chosen at install); the **Notification language** above is a separate control on the Settings page.

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
