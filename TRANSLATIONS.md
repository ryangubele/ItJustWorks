# Translations

It Just Works™ ships its in-game menu (the MCM) and manual in ten languages.

[简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Important: everything but English was machine-translated

The English is written by the author. Every other language was translated by a large language model, not by a native speaker. The translations are careful and technically consistent - filenames, settings, and terms like `Editor ID`, `Form ID`, and `Papyrus` are deliberately left untranslated so you can still cross-reference them - but no fluent human has reviewed them.

If you speak one of these languages and something reads wrong, stiff, or plain incorrect: **please improve it.** Open a pull request, or send corrections however suits you - the credit is yours, and the gratitude is guaranteed. A native pass is the one thing a machine can't give this, and it's welcome for every language, including English.

You don't have to be fluent to help, either. If a line in the menu looks **cut off** or spills past the edge of the panel - likeliest in Chinese or Japanese, where the characters are wider - that's a genuinely useful report, and an easy one to send: a screenshot and the language is enough.

## What's translated

- **The MCM menu**
- **The manual** (`docs/manual.<lang>.md`)
- **The in-game pop-up notifications** - follow the **Notification language** setting on the MCM's **Settings** page; the installer seeds it from your menu-language choice.

## What's deliberately English

- **The `See? It Just Works!` sign-off** - the joke is English-native. Taste, not a limitation.
- **The Papyrus diagnostic log** - lines the mod writes when you turn logging on stay English on purpose. They're a structured, greppable `key=value` dialect meant to be searched and pasted into a bug report; translating them would break a lot of usefulness for little benefit.

## Languages

The default Skyrim font for English players can't render non-Latin scripts, so using language endonyms in the MCM makes the mod look broken. As a workaround, the **Notification language** setting lists the ten languages by their English names. Find yours here if you don't already know it:

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

The **menu** language follows Skyrim's game language file unless you override it (installer default-menu step, or by-hand rename onto `fth_ItJustWorks_ENGLISH.txt`). The **Notification language** control on Settings is separate: the installer seeds it when you pick a default menu language, but a by-hand menu rename does not. Set it to match if notifications are in the wrong language.

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
