# Korzystanie z It Just Works™

## Co robi

Skyrim używa *scen* do rozmów, cutscenek i innych skryptowanych momentów. Czasem scena nigdy się nie kończy. To może po cichu blokować kolejne sceny — zadanie, które nie idzie dalej, bez błędu, bez awarii. Ten mod pilnuje sceny, w której jesteś, ostrzega, jeśli siedzisz w niej za długo, pokazuje, co to jest, i pozwala ją zatrzymać, gdy się zacina.

**W skrócie:** zostaw domyślne ustawienia i graj. Gdy dostaniesz alert, otwórz **Menu konfiguracji modów > It Just Works**.

Wymaga **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** oraz **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (z `Load EditorIDs = true`, jeśli chcesz nazwy zamiast numerów ID). Uwagi instalacyjne są na [stronie moda](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pięć stron: **Scena**, **Strażnik**, **Ustawienia**, **Diagnostyka**, **Odinstaluj**.

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
- **Język powiadomień** — język własnych wyskakujących powiadomień moda (toastów w rogu). Ustaw go zgodnie z językiem swojego menu. Domyślnie angielski; niezależny od ustawienia języka gry.
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

- **Strażnik** — czy sprawdzenie w tle działa:
  - **Działa** — w porządku
  - **Budzi się** — normalne tuż po przeładowaniu
  - **Opóźniony** — nadal działa, ale sprawdzenia są wolniejsze niż zwykle (zajęta gra)
  - **Wyłączony (sprawdzanie wyłączone)** — ustawiłeś **Sprawdzaj co** na 0
  - **Uśpiony (wyłączony)** — **Włączony** jest wyłączony na stronie **Ustawienia**

- **Ostatnia samonaprawa** — mod czasem poprawia własną księgowość (często po przeładowaniu). Wiersz tutaj jest normalny.

- **Wersja**

---

## Rozwiązywanie problemów

### Sceny wyświetlają się jako numery ID, a nie nazwy

po3 Tweaks nie wczytuje Editor ID. W `po3_Tweaks.ini` ustaw `Load EditorIDs = true` i zrestartuj Skyrim; lampka *Editor ID wczytane* na stronie **Diagnostyka** to potwierdza. Menadżery modów mogą nadpisać ten plik przy wdrażaniu lub aktualizacji, więc edytuj kopię *wewnątrz* moda Tweaks (albo mały mod override, który wygrywa), a nie tylko luźny plik w `Data`:

- **MO2:** folder moda Tweaks w lewym panelu albo Overwrite / mod o wyższym priorytecie.
- **Vortex:** folder staging Tweaks albo mod override. Sprawdź ponownie po każdej aktualizacji.

**Form ID** i tak się wyświetla, więc nigdy nie zostajesz całkiem po ciemku.

### Powiadomienia są w niewłaściwym języku

Mod ma dwa niezależne ustawienia języka; to jest to dla jego własnych wyskakujących powiadomień. Ustaw **Ustawienia > Język powiadomień** na swój język — steruje toastami w rogu (alert o zaciętej scenie, podpowiedź o nazwach, wyniki Zatrzymania). Jest niezależne od języka gry i od języka menu poniżej. Angielski jest domyślny i zapasowy, więc nieprzetłumaczony wiersz czyta się po angielsku, zamiast się psuć.

### Menu jest w niewłaściwym języku

Menu MCM podąża za **ustawieniem języka** gry, a nie za językiem powiadomień powyżej. Skyrim wczytuje plik tłumaczenia pasujący do języka gry, więc angielska gra pokazuje angielskie menu, nawet jeśli zainstalowałeś inny język. Dwa sposoby, by to zmienić:

- **Instalator:** zaznacz swój język w kroku 1, potem wybierz go jako domyślny język menu w kroku 2 (nadpisuje angielski plik i zachowuje angielski `.bak`).
- **Ręcznie:** zmień nazwę `Interface\Translations\fth_ItJustWorks_POLISH.txt` na `fth_ItJustWorks_ENGLISH.txt`, zastępując angielski plik.

### Menu lub powiadomienia pokazują nieczytelne albo zniekształcone znaki

Tekst jest poprawny — twoja gra po prostu nie ma czcionki zdolnej narysować tych znaków, więc wyświetla się jako bełkot. Standardowa czcionka Skyrima obejmuje litery łacińskie i zachodnioeuropejskie, ale nie cyrylicę, chiński, japoński ani niektóre znaki środkowoeuropejskie. Jeśli używasz menu lub powiadomień w jednym z tych języków, zainstaluj **moda z czcionką**, który je zawiera; większość nieangielskich konfiguracji już go ma. Jeśli twoja nie, przeszukaj Nexus w poszukiwaniu czcionki obejmującej twój język — [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) to szeroki punkt wyjścia.

### Żaden alert się nie pojawia

Sprawdź status **Strażnika** na stronie **Diagnostyka**, potem pokrętła **Strażnika**:

- Status **Uśpiony** — mod jest wyłączony. Włącz **Włączony** (Ustawienia).
- Status **Wyłączony** — **Sprawdzaj co** jest na 0. Ustaw z powrotem na 10–240 s.
- **Ostrzeż po** jest na **0** — to wyłącza alert. Ustaw żądaną liczbę minut.

**Czas w scenie** zeruje się przy przeładowaniu, więc scena ostrzega dopiero, gdy jesteś w niej nieprzerwanie dłużej niż czas ostrzeżenia w tej sesji. Nawet bez toasta menu zawsze pokazuje bieżącą scenę i jak długo w niej jesteś.

### Zatrzymanie sceny nie usunęło sceny

Zatrzymanie ani razu nie zawiodło — ani przez 14 lat odblokowywania zapisów, najpierw prowizorycznymi jednorazowymi wersjami, a teraz tym. Więc jeśli kiedyś zgłosi, że scena się nie zakończyła, znalazłeś coś naprawdę nowego — co jest ekscytujące, nie niepokojące. Zaskoczenie to miejsce, gdzie rodzi się nauka. Nie ma jeszcze znanej przyczyny i nic nie jest obiecane, ale kompletny log to najlepsza szansa, by ją wytropić. Włącz logowanie Papyrus, ustaw **Ustawienia > Log diagnostyczny** na **Każde sprawdzenie** i włącz każdą opcję logowania lub debugowania, jaką znajdziesz w całej swojej kolejności wczytywania — tak, by jeśli zdarzy się ponownie, zostało uchwycone. Potem wyślij kompletny `Papyrus.0.log` jako zgłoszenie błędu (kanały poniżej). W międzyczasie przeładuj sprzed zacięcia, żeby grać dalej.

### Zgłaszanie błędu albo prośba o pomoc

Przy błędzie ustaw **Ustawienia > Log diagnostyczny** na **Zdarzenia**, odtwórz problem, potem wyjdź. Z włączonym logowaniem Papyrus (wiersze `Skyrim.ini` są w **Ustawieniach**) otwórz `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` i szukaj `fth_IJW`. Dołącz to, **Form ID** sceny i **Zadanie nadrzędne** oraz to, co robiłeś, gdy się zacięło.

Gdzie to wysłać:

- **Zgłoszenia błędów:** [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) na stronie moda albo [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Pytania i ogólna pomoc:** [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) na stronie moda.

---

## Odinstaluj

**Usunąć na dobre:**

1. Na stronie **Ustawienia** wyłącz **Włączony**.
2. Zapisz, wyjdź na pulpit.
3. Usuń moda w menedżerze (lub ręcznie).

Bezpieczne do usunięcia w trakcie przejścia. Skyrim może zostawić w zapisie mały martwy stub skryptu, jak inne skryptowane mody; gra go ignoruje. Opcjonalnie: cleaner zapisu (np. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** w FallrimTools) może usunąć stuby po deinstalacji — używaj cleanerów ostrożnie, tylko na to, co chciałeś usunąć. Możesz zostawić ten mod zainstalowany, czyszcząc śmieci z *innych* modów.
