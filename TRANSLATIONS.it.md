# Traduzioni

It Just Works™ distribuisce il suo menu di gioco (l'MCM) e il suo manuale in dieci lingue.

**Leggi questa pagina nella tua lingua:** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Importante: tutto tranne l'inglese è stato tradotto automaticamente

L'inglese è scritto dall'autore. **Ogni altra lingua è stata tradotta da un'IA (un grande modello linguistico), non da un madrelingua.** Le traduzioni sono accurate e tecnicamente coerenti - i nomi dei file, le impostazioni e i termini come `Editor ID`, `Form ID` e `Papyrus` sono deliberatamente lasciati non tradotti così da poterli ancora incrociare come riferimento - ma nessun essere umano che parli fluentemente la lingua le ha riviste.

Se parli una di queste lingue e qualcosa suona sbagliato, rigido o semplicemente scorretto: **per favore, miglioralo.** È proprio questo il senso dell'open source e di una licenza condivisibile. Apri una pull request, oppure invia le correzioni come preferisci - il merito è tuo, e la gratitudine è garantita. Una revisione madrelingua è l'unica cosa che una macchina non può dare a tutto questo, ed è benvenuta per ogni lingua, inglese incluso.

Non serve nemmeno parlare fluentemente per aiutare. Se una riga nel menu sembra **tagliata** o sborda dal bordo del pannello - più probabile in cinese o giapponese, dove i caratteri sono più larghi - è una segnalazione davvero utile, e facile da inviare: bastano uno screenshot e la lingua. La colonna del menu è stretta, quindi una riga occasionalmente troppo lunga è un adattamento di visualizzazione da rifinire, non una traduzione difettosa.

## Cosa è tradotto

- **Il menu MCM** - completamente tradotto: ogni etichetta di opzione, ogni descrizione di aiuto e le stringhe di stato dinamiche che gli script inviano al menu (i suggerimenti di attivazione/annullamento di Stop, lo stato del watchdog, le ultime frasi di auto-riparazione).
- **Il manuale** (`docs/manual.<lang>.md`) - completamente tradotto.
- **Le notifiche pop-up di gioco** - tradotte. L'avviso del watchdog, l'avviso «i nomi sono errati», i risultati di Stop e la lettura del tasto di scelta rapida seguono l'impostazione **Notification language** nella pagina **Settings** dell'MCM, in tutte e dieci le lingue; l'installer la imposta in base alla tua scelta della lingua del menu.

## Cosa è deliberatamente in inglese

- **La firma `See? It Just Works!`** - la battuta è nativa dell'inglese. Questione di gusto, non un limite.
- **Il log di diagnostica Papyrus** - le righe opzionali `[fth_IJW] …` che la mod scrive quando attivi la registrazione restano in inglese di proposito. Sono un dialetto `key=value` strutturato e «greppabile», pensato per essere cercato e incollato in una segnalazione di bug; tradurle romperebbe questa ricercabilità e si diramerebbe in una matrice ingestibile per lingua, senza vantaggio per nessuno.

## Lingue

L'impostazione **Notification language** elenca le dieci lingue con i loro nomi inglesi, così il menu a discesa resta leggibile qualunque font tu abbia. Trova la tua qui (dall'alto in basso corrisponde all'ordine del menu a discesa):

| Nel menu | La tua lingua | Codice Skyrim |
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

La lingua del **menu** segue la lingua del tuo gioco Skyrim (scelta all'installazione); la **Notification language** qui sopra è un controllo separato nella pagina Settings.

## Manuali

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
