# Korzystanie z It Just Works™

## Co robi

Skyrim używa *scen* do rozmów, cutscenek i innych skryptowanych momentów. Czasem scena nigdy się nie kończy. To może po cichu blokować kolejne sceny — zadanie, które nie idzie dalej, bez błędu, bez awarii. Ten mod pilnuje sceny, w której jesteś, ostrzega, jeśli siedzisz w niej za długo, pokazuje, co to jest, i pozwala ją zatrzymać, gdy się zacina.

**W skrócie:** zostaw domyślne ustawienia i graj. Gdy dostaniesz alert, otwórz **Menu konfiguracji modów > It Just Works**.

Wymaga **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** oraz **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (z `Load EditorIDs = true`, jeśli chcesz nazwy zamiast numerów ID). Uwagi instalacyjne są na [stronie moda](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Trzy strony w menu: **Scena**, **Diagnostyka**, **Odinstaluj**.

---

## Menu w innym języku

Mod dostarcza tłumaczenia menu — wybierz je w instalatorze. Skyrim wczytuje plik pasujący do **ustawienia języka** gry. Angielska gra + inny zainstalowany język nadal czyta angielski plik menu, dopóki go nie nadpiszesz.

**Instalator:** zaznacz język w kroku 1, potem ustaw go jako domyślny język menu w kroku 2 (nadpisuje angielski plik; zachowuje angielski `.bak`).

**Ręcznie:** zmień nazwę `Interface\Translations\fth_ItJustWorks_POLISH.txt` na `fth_ItJustWorks_ENGLISH.txt` (zastąp angielski plik).

---

## Scena

### W czym jesteś

Na żywo odczyt bieżącej sceny albo **None**. Otwórz menu, by dostać świeży odczyt.

- **Czas w scenie** — wiersz, który tu zwykle ma znaczenie: mniej więcej jak długo w niej jesteś w tej sesji (`~` oznacza przybliżenie). To sygnał zacięcia albo jego braku. **Przeładowanie gry zeruje ten timer.** Długa ciągła gra po przeładowaniu wciąż może ostrzec; skakanie przez przeładowania bez dłuższego pozostania w grze — nie.
- **Scena** — nazwa, gdy nazwy są dostępne; w przeciwnym razie numer ID (zob. Editor ID w Diagnostyce).
- **Form ID** — surowy ID, zawsze widoczny. Przydatny w konsoli lub zgłoszeniu błędu; nie potrzebujesz go, by zatrzymać scenę — do tego jest przycisk poniżej.
- **Zadanie nadrzędne** — do którego zadania należy ta scena, gdy chcesz szerszy kontekst.

### Zatrzymaj scenę

Jeśli uważasz, że scena się zacięła, to ją kończy.

1. Naciśnij **Zatrzymaj scenę** raz — wiersz potwierdza, że jest uzbrojona.
2. Naciśnij ponownie, by anulować, albo **zamknij menu**, by zatrzymać. Zatrzymanie następuje przy zamknięciu menu.

Zatrzymuj tylko scenę, którą uważasz za zaciętą. Zatrzymanie normalnej może coś zepsuć. Zatrzymanie zaciętej może wywołać krótką salwę opóźnionych zdarzeń, gdy gra nadrabia — to oczekiwane, nie nowy problem.

**Odśwież** ponownie odczytuje bieżącą scenę bez zamykania menu. Otwarcie i tak bierze świeży odczyt; użyj tego, gdy menu jest otwarte dłużej i chcesz aktualizacji — zwłaszcza z modami takimi jak [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), które trzymają grę w ruchu przy otwartych menu.

### Ostatnie sceny

Ostatnie dziesięć scen, najnowsza pierwsza, z przybliżonym czasem trwania. Ten sam rodzaj przybliżonego czasu co wyżej (przeładowanie nie trzyma stopera z wcześniejszych sesji).

### Strażnik

Na tej samej stronie. Pilnuje, żebyś nie musiał.

- **Ostrzeż po** — minuty w jednej scenie przed alertem. Domyślnie **3**. **0** = nigdy nie ostrzegaj.
- **Sprawdzaj co** — sekundy między sprawdzeniami. Domyślnie **30**. **0** = wyłącza strażnika.

Alert to dwa wiersze w rogu, na przykład:

> scene blocking others ~3m  
> See? It Just Works!

Raz na scenę, dopóki jej nie opuścisz albo scena się nie zmieni. Przegapiłeś toast? Otwórz menu — odczyt nadal pokazuje, w czym jesteś i jak długo. Mod nie zatrzymuje sceny za ciebie; do tego jest **Zatrzymaj scenę**.

### Hotkey

- **Nazwij bieżącą scenę** — przypisz klawisz; naciśnij, by zobaczyć nazwę bieżącej sceny bez otwierania menu.
- **Wyczyść klawisz** — usuwa przypisanie. ESC go tu nie czyści (ESC to Pauza w tym menu).

---

## Diagnostyka

- **Editor ID wczytane** — kontrolka stanu, nie przełącznik (kliknięcie wraca na miejsce).
  - **Świeci** — nazwy są włączone.
  - **Zgaszona** — zobaczysz numery ID; mod i tak działa.

  Nazwy włączone: w `po3_Tweaks.ini` ustaw `Load EditorIDs = true`, zrestartuj Skyrim. Mod mówi to też raz, gdy po raz pierwszy zauważy, że nazwy są wyłączone.

- **Strażnik** — czy sprawdzenie w tle działa:
  - **Działa** — w porządku
  - **Budzi się** — normalne tuż po przeładowaniu
  - **Opóźniony** — nadal działa, ale sprawdzenia są wolniejsze niż zwykle (zajęta gra)
  - **Wyłączony (sprawdzanie wyłączone)** — ustawiłeś Sprawdzaj co na 0
  - **Uśpiony (wyłączony)** — Włączony jest wyłączony na Odinstaluj

- **Ostatnia samonaprawa** — mod czasem poprawia własną księgowość (często po przeładowaniu). Wiersz tutaj jest normalny. To nie usterka i nie trzeba go czyścić.

- **Log diagnostyczny** — ile idzie do logu Papyrus. Zostaw **Wyłączony** przy normalnej grze. Użyj **Zdarzenia** przy zgłaszaniu błędu; **Każde sprawdzenie** tylko gdy tropisz problem z timingiem, potem wróć.

  Logowanie działa tylko, gdy gra zapisuje logi Papyrus. W `Documents\My Games\Skyrim Special Edition\` edytuj `Skyrim.ini` lub `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restart. Plik logu: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Szukaj `fth_IJW`.

- **Wersja** — numer buildu, do wątków pomocy i aktualizacji.

---

## Wyłączenie lub usunięcie

**Odłożyć na bok:** strona Odinstaluj → **Włączony** wyłączony. Strażnik i hotkey się zatrzymują; włącz później i wznawia. Zapis jest w porządku.

**Usunąć na dobre:**

1. Wyłącz **Włączony**.
2. Zapisz, wyjdź na pulpit.
3. Usuń moda w menedżerze (lub ręcznie).

Bezpieczne do usunięcia w trakcie przejścia. Skyrim może zostawić w zapisie mały martwy stub skryptu, jak inne skryptowane mody; gra go ignoruje. Opcjonalnie: cleaner zapisu (np. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** w FallrimTools) może usunąć stuby po deinstalacji — używaj cleanerów ostrożnie, tylko na to, co chciałeś usunąć. Możesz zostawić ten mod zainstalowany, czyszcząc śmieci z *innych* modów.
