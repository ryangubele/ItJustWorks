# Korzystanie z It Just Works™

## Co robi

Skyrim używa *scen* do rozmów, cutscenek i innych skryptowanych momentów. Czasem scena nigdy się nie kończy. To może po cichu blokować kolejne sceny — zadanie, które nie idzie dalej, bez błędu, bez awarii. Ten mod pilnuje sceny, w której jesteś, ostrzega, jeśli siedzisz w niej za długo, pokazuje, co to jest, i pozwala ją zatrzymać, gdy się zacina.

**W skrócie:** zostaw domyślne ustawienia i graj. Gdy dostaniesz alert, otwórz **Menu konfiguracji modów > It Just Works**.

Wymaga **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** oraz **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (z `Load EditorIDs = true`, jeśli chcesz nazwy zamiast numerów ID). Uwagi instalacyjne są na [stronie moda](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pięć stron: **Scena**, **Strażnik**, **Ustawienia**, **Diagnostyka**, **Odinstaluj**.

---

## Menu w innym języku

Mod dostarcza tłumaczenia menu — wybierz je w instalatorze. Skyrim wczytuje plik pasujący do **ustawienia języka** gry. Angielska gra + inny zainstalowany język nadal czyta angielski plik menu, dopóki go nie nadpiszesz.

**Instalator:** zaznacz język w kroku 1, potem ustaw go jako domyślny język menu w kroku 2 (nadpisuje angielski plik; zachowuje angielski `.bak`).

**Ręcznie:** zmień nazwę `Interface\Translations\fth_ItJustWorks_POLISH.txt` na `fth_ItJustWorks_ENGLISH.txt` (zastąp angielski plik).

---

## Scena

### W czym jesteś

Na żywo odczyt bieżącej sceny albo **None**. Otwórz menu, by dostać świeży odczyt.

- **Czas w scenie** — mniej więcej jak długo jesteś w tej scenie; przeładowanie gry to zeruje. To sygnał zacięcia albo jego braku.
- **Scena** — nazwa, gdy nazwy są dostępne; w przeciwnym razie numer ID.
- **Form ID** — surowy ID, zawsze widoczny. Przydatny w konsoli lub zgłoszeniu błędu.
- **Zadanie nadrzędne** — do którego zadania należy ta scena.

### Zatrzymaj scenę

Jeśli uważasz, że scena się zacięła, to ją kończy.

1. Naciśnij **Zatrzymaj scenę** raz — wiersz potwierdza, że jest uzbrojona.
2. Naciśnij ponownie, by anulować, albo **zamknij menu**, by zatrzymać.

Zatrzymuj tylko scenę, którą uważasz za zaciętą. Zatrzymanie normalnej może coś zepsuć. Zatrzymanie zaciętej może (rzadko) wywołać krótką salwę opóźnionych zdarzeń, gdy gra nadrabia.

**Odśwież** ponownie odczytuje bieżącą scenę bez zamykania menu. W podstawowym Skyrimie gra jest zwykle wstrzymana w menu, więc **Odśwież** raczej się nie przyda. Jeśli używasz moda znoszącego pauzę, takiego jak [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), pozwala to odświeżyć menu bez ponownego otwierania.

### Ostatnie sceny

Ostatnie dziesięć scen, najnowsza pierwsza, z przybliżonym czasem trwania. Ten sam rodzaj przybliżonego czasu co wyżej.

---

## Strażnik

Pilnuje, żebyś nie musiał.

- **Ostrzeż po** — minuty w jednej scenie przed alertem. Domyślnie **3**. **0** = nigdy nie ostrzegaj.
- **Sprawdzaj co** — sekundy między sprawdzeniami. Domyślnie **30**. **0** = wyłącza strażnika.

Alert to dwa wiersze w rogu, na przykład:

> scene blocking others ~3m  
> See? It Just Works!

Raz na scenę, dopóki jej nie opuścisz albo scena się nie zmieni. Przegapiłeś toast? Otwórz menu — odczyt nadal pokazuje, w czym jesteś i jak długo. Mod nie zatrzymuje sceny za ciebie; do tego jest **Zatrzymaj scenę**.

---

## Ustawienia

- **Włączony** — domyślnie włączony. Wyłącz, by odłożyć mod na bok bez odinstalowania.
- **Lekkość** — domyślnie włączone. Powiadomienia zachowują lekki ton; wyłącz, aby uzyskać zwykły tekst. Zmienia się tylko tekst, nigdy działanie moda.
- **Nazwij bieżącą scenę** — przypisz klawisz; naciśnij, by zobaczyć nazwę bieżącej sceny bez otwierania menu.
- **Wyczyść klawisz** — usuwa przypisanie.
- **Log diagnostyczny** — ile idzie do logu Papyrus. Zostaw **Wyłączony** przy normalnej grze. Użyj **Zdarzenia** przy zgłaszaniu błędu; **Każde sprawdzenie** tylko gdy tropisz problem z timingiem, potem wyłącz z powrotem. Może wpływać na wydajność, zwłaszcza przy **Każde sprawdzenie**.

  Logowanie działa tylko, gdy gra zapisuje logi Papyrus. W `Documents\My Games\Skyrim Special Edition\` edytuj `Skyrim.ini` lub `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restart. Plik logu: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Szukaj `fth_IJW`.

---

## Diagnostyka

- **Editor ID wczytane** — wskaźnik. Gdy świeci, nazwy na **Scenie** i zadaniu nadrzędnym; gdy zgaszona, numery ID. **Form ID** i tak zawsze pozostaje surowym `0x…`.

  Nazwy włączone: w `po3_Tweaks.ini` ustaw `Load EditorIDs = true`, zrestartuj Skyrim. Mod mówi to też raz, gdy po raz pierwszy zauważy, że nazwy są wyłączone. Menadżery modów mogą nadpisać ten plik przy wdrażaniu lub aktualizacji — edytuj kopię *wewnątrz* moda Tweaks (albo mały mod override, który wygrywa), a nie tylko luźny plik w `Data`. **MO2:** folder moda w lewym panelu albo Overwrite / mod o wyższym priorytecie. **Vortex:** folder staging Tweaks albo mod override; sprawdź ponownie po aktualizacjach.

- **Strażnik** — czy sprawdzenie w tle działa:
  - **Działa** — w porządku
  - **Budzi się** — normalne tuż po przeładowaniu
  - **Opóźniony** — nadal działa, ale sprawdzenia są wolniejsze niż zwykle (zajęta gra)
  - **Wyłączony (sprawdzanie wyłączone)** — ustawiłeś **Sprawdzaj co** na 0
  - **Uśpiony (wyłączony)** — **Włączony** jest wyłączony na stronie **Ustawienia**

- **Ostatnia samonaprawa** — mod czasem poprawia własną księgowość (często po przeładowaniu). Wiersz tutaj jest normalny.

- **Wersja**

---

## Odinstaluj

**Usunąć na dobre:**

1. Na stronie **Ustawienia** wyłącz **Włączony**.
2. Zapisz, wyjdź na pulpit.
3. Usuń moda w menedżerze (lub ręcznie).

Bezpieczne do usunięcia w trakcie przejścia. Skyrim może zostawić w zapisie mały martwy stub skryptu, jak inne skryptowane mody; gra go ignoruje. Opcjonalnie: cleaner zapisu (np. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** w FallrimTools) może usunąć stuby po deinstalacji — używaj cleanerów ostrożnie, tylko na to, co chciałeś usunąć. Możesz zostawić ten mod zainstalowany, czyszcząc śmieci z *innych* modów.
