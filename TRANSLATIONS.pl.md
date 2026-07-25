# Tłumaczenia

It Just Works™ dostarcza swoje menu w grze (MCM) oraz instrukcję w dziesięciu językach.

**Przeczytaj tę stronę w swoim języku:** [English](TRANSLATIONS.md) · [简体中文](TRANSLATIONS.zh.md) · [Čeština](TRANSLATIONS.cs.md) · [Français](TRANSLATIONS.fr.md) · [Deutsch](TRANSLATIONS.de.md) · [Italiano](TRANSLATIONS.it.md) · [日本語](TRANSLATIONS.ja.md) · [Polski](TRANSLATIONS.pl.md) · [Русский](TRANSLATIONS.ru.md) · [Español](TRANSLATIONS.es.md)

## Ważne: wszystko oprócz angielskiego przetłumaczyła maszyna

Angielski pisze autor. **Każdy inny język został przetłumaczony przez SI (duży model językowy), a nie przez rodzimego użytkownika.** Tłumaczenia są staranne i technicznie spójne - nazwy plików, ustawienia oraz terminy takie jak `Editor ID`, `Form ID` i `Papyrus` celowo pozostawiono nieprzetłumaczone, byś nadal mógł je odnieść do siebie - ale żaden biegły człowiek ich nie sprawdził.

Jeśli mówisz w jednym z tych języków i coś brzmi źle, sztywno albo wprost niepoprawnie: **popraw to, proszę.** O to właśnie chodzi w otwartym oprogramowaniu i w licencji, którą można dzielić. Otwórz pull request albo prześlij poprawki, jak ci wygodnie - uznanie należy do ciebie, a wdzięczność gwarantowana. Korekta przez rodzimego użytkownika to jedyna rzecz, której maszyna tu nie da, i jest mile widziana w każdym języku, także w angielskim.

Nie musisz też być biegły, by pomóc. Jeśli wiersz w menu wygląda na **ucięty** albo wychodzi poza krawędź panelu - najpewniej po chińsku lub japońsku, gdzie znaki są szersze - to naprawdę przydatne zgłoszenie, a przy tym łatwe do wysłania: wystarczy zrzut ekranu i język. Kolumna menu jest wąska, więc sporadyczny zbyt długi wiersz to kwestia dopasowania wyświetlania do przycięcia, a nie zepsute tłumaczenie.

## Co jest przetłumaczone

- **Menu MCM** - w pełni przetłumaczone: każda etykieta opcji, każdy opis pomocy oraz dynamiczne łańcuchy stanu, które skrypty wysyłają do menu (podpowiedzi uzbrajania/anulowania Stop, stan strażnika, ostatnie frazy autonaprawy).
- **Instrukcja** (`docs/manual.<lang>.md`) - w pełni przetłumaczona.
- **Wyskakujące powiadomienia w grze** - przetłumaczone. Alert strażnika, komunikat „nazwy są nie te", wyniki Stop i odczyt skrótu klawiszowego podążają za ustawieniem **Język powiadomień** na stronie **Ustawienia** w MCM, we wszystkich dziesięciu językach; instalator ustawia je na podstawie wybranego języka menu.

## Co celowo pozostaje po angielsku

- **Zakończenie `See? It Just Works!`** - żart jest rodzimy dla angielskiego. Kwestia gustu, nie ograniczenia.
- **Dziennik diagnostyczny Papyrus** - opcjonalne wiersze `[fth_IJW] …`, które mod zapisuje po włączeniu logowania, celowo pozostają po angielsku. To ustrukturyzowany, przeszukiwalny grepem dialekt `key=value`, przeznaczony do wyszukiwania i wklejania do zgłoszenia błędu; tłumaczenie zepsułoby tę przeszukiwalność i rozgałęziłoby się w niemożliwą do utrzymania macierz per język, bez pożytku dla kogokolwiek.

## Języki

Ustawienie **Notification language** wymienia dziesięć języków po ich angielskich nazwach, aby lista rozwijana pozostała czytelna niezależnie od posiadanej czcionki. Znajdź swój tutaj (kolejność z góry na dół odpowiada kolejności listy):

| W menu | Twój język | Kod Skyrim |
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

Język **menu** podąża za plikiem języka gry Skyrim, chyba że go nadpiszesz (krok domyślnego menu w instalatorze albo ręczna zmiana nazwy na `fth_ItJustWorks_ENGLISH.txt`). Element sterujący **Język powiadomień** na stronie Ustawienia jest osobny: instalator może go ustawić, gdy wybierzesz domyślny język menu, ale ręczna zmiana nazwy pliku menu tego nie robi — ustaw enum tak, by pasował, jeśli toasty pozostają po angielsku.

## Instrukcje

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
