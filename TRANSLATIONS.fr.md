# Traductions

It Just Works™ propose son menu en jeu (le MCM) et son manuel en dix langues.

**Lisez cette page dans votre langue :** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Important : tout sauf l'anglais a été traduit automatiquement

L'anglais est rédigé par l'auteur. **Toutes les autres langues ont été traduites par une IA (un grand modèle de langage), et non par un locuteur natif.** Les traductions sont soignées et techniquement cohérentes - les noms de fichiers, les réglages et les termes comme `Editor ID`, `Form ID` et `Papyrus` sont délibérément laissés non traduits afin que vous puissiez encore les recouper - mais aucun humain parlant couramment la langue ne les a relues.

Si vous parlez l'une de ces langues et qu'une formulation vous semble erronée, maladroite ou tout simplement incorrecte : **améliorez-la, s'il vous plaît.** C'est là tout l'intérêt de l'open source et d'une licence partageable. Ouvrez une pull request, ou envoyez vos corrections par le moyen qui vous convient - le crédit vous revient, et la gratitude est garantie. Une relecture par un locuteur natif est la seule chose qu'une machine ne peut pas offrir, et elle est la bienvenue pour toutes les langues, y compris l'anglais.

Nul besoin de parler couramment pour aider, d'ailleurs. Si une ligne du menu semble **coupée** ou déborde du bord du panneau - le plus probable en chinois ou en japonais, où les caractères sont plus larges - c'est un signalement réellement utile, et facile à envoyer : une capture d'écran et la langue suffisent. La colonne du menu est étroite, donc une ligne occasionnellement trop longue est un ajustement d'affichage à corriger, et non une traduction défectueuse.

## Ce qui est traduit

- **Le menu MCM** - entièrement traduit : chaque libellé d'option, chaque description d'aide, et les chaînes d'état dynamiques que les scripts poussent dans le menu (les indications d'armement/annulation de Stop, l'état du chien de garde, les dernières formules d'auto-réparation).
- **Le manuel** (`docs/manual.<lang>.md`) - entièrement traduit.
- **Les notifications contextuelles en jeu** - traduites. L'alerte du chien de garde, l'avis « les noms sont incorrects », les résultats de Stop et l'affichage de la touche de raccourci suivent le réglage **Langue des notifications** de la page **Paramètres** du MCM, dans les dix langues ; l'installateur l'initialise à partir de votre choix de langue du menu.

## Ce qui est volontairement en anglais

- **La signature `See? It Just Works!`** - la blague est native de l'anglais. Question de goût, pas une limitation.
- **Le journal de diagnostic Papyrus** - les lignes optionnelles `[fth_IJW] …` que le mod écrit lorsque vous activez la journalisation restent en anglais volontairement. C'est un dialecte `key=value` structuré et « greppable », conçu pour être recherché et collé dans un rapport de bug ; les traduire casserait cette capacité de recherche et se démultiplierait en une matrice ingérable par langue, sans bénéfice pour personne.

## Langues

Le réglage **Langue des notifications** liste les dix langues par leur nom anglais, afin que le menu déroulant reste lisible quelle que soit la police dont vous disposez. Trouvez la vôtre ici (de haut en bas, cela correspond à l'ordre du menu déroulant) :

| Dans le menu | Votre langue | Code Skyrim |
|-------------|--------------|-------------|
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

La langue du **menu** suit le fichier de langue du jeu Skyrim, sauf si vous la remplacez (étape de langue de menu par défaut de l'installateur, ou renommage à la main par-dessus `fth_ItJustWorks_ENGLISH.txt`). Le contrôle **Langue des notifications** sur la page Paramètres est distinct : l'installateur peut l'initialiser lorsque vous choisissez une langue de menu par défaut, mais un renommage manuel du menu ne le fait pas - réglez l'énumération pour qu'elle corresponde si les toasts restent en anglais.

## Manuels

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
