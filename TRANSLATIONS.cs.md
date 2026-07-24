# Překlady

It Just Works™ nabízí svou herní nabídku (MCM) i manuál v deseti jazycích.

**Přečtěte si tuto stránku ve svém jazyce:** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Důležité: vše kromě angličtiny bylo strojově přeloženo

Angličtinu píše autor. **Každý další jazyk přeložila umělá inteligence (velký jazykový model), nikoli rodilý mluvčí.** Překlady jsou pečlivé a technicky konzistentní – názvy souborů, nastavení a termíny jako `Editor ID`, `Form ID` a `Papyrus` jsou záměrně ponechány nepřeložené, abyste je mohli i nadále vzájemně dohledávat – ale žádný plynulý člověk je nezkontroloval.

Pokud některým z těchto jazyků mluvíte a něco zní špatně, kostrbatě nebo je to prostě nesprávné: **prosím, vylepšete to.** Právě o tom je celý smysl otevřeného zdroje a sdílitelné licence. Otevřete pull request nebo pošlete opravy, jakkoli vám to vyhovuje – zásluha je vaše a vděčnost zaručená. Úprava od rodilého mluvčího je jediná věc, kterou tomuto projektu stroj dát nemůže, a je vítána u každého jazyka, včetně angličtiny.

Abyste pomohli, nemusíte být ani plynulí. Pokud některý řádek v nabídce vypadá **oříznutě** nebo přetéká přes okraj panelu – nejpravděpodobněji v čínštině nebo japonštině, kde jsou znaky širší – je to opravdu užitečné hlášení a snadno se posílá: stačí snímek obrazovky a jazyk. Sloupec nabídky je úzký, takže občasný příliš dlouhý řádek je otázkou přizpůsobení zobrazení k oříznutí, nikoli vadný překlad.

## Co je přeloženo

- **Nabídka MCM** – plně přeložena: každý popisek volby, každý text nápovědy i dynamické stavové řetězce, které skripty vkládají do nabídky (pokyny k aktivaci/zrušení Stop, stav hlídače, poslední fráze samoopravy).
- **Manuál** (`docs/manual.<lang>.md`) – plně přeložen.
- **Herní vyskakovací oznámení** – přeložena. Upozornění hlídače, oznámení „názvy jsou vypnuté", výsledky Stop a výpis klávesových zkratek se řídí nastavením **Notification language** na stránce **Settings** v MCM, ve všech deseti jazycích; instalátor je předvyplní podle vámi zvoleného jazyka nabídky.

## Co je záměrně anglicky

- **Zakončení `See? It Just Works!`** – tento vtip je rodilý anglicky. Věc vkusu, nikoli omezení.
- **Diagnostický protokol Papyrus** – volitelné řádky `[fth_IJW] …`, které mod zapisuje, když zapnete protokolování, zůstávají záměrně anglicky. Jde o strukturovaný, grep-ovatelný dialekt `key=value` určený k vyhledávání a vkládání do hlášení o chybě; jejich překlad by tuto grep-ovatelnost narušil a rozvětvil se do neudržovatelné matice podle jazyků, k ničímu prospěchu.

## Jazyky

Nastavení **Notification language** vypisuje těchto deset jazyků pod jejich anglickými názvy, takže rozevírací seznam zůstává čitelný, ať máte jakékoli písmo. Najděte ten svůj zde (pořadí shora dolů odpovídá pořadí v rozevíracím seznamu):

| V nabídce | Váš jazyk | Kód Skyrimu |
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

Jazyk **nabídky** se řídí jazykem vaší hry Skyrim (zvoleným při instalaci); výše uvedený **Notification language** je samostatný ovládací prvek na stránce Settings.

## Manuály

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
