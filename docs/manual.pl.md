# Korzystanie z It Just Works™

## Co robi

Skyrim używa *scen* do rozmów, cutscenek i innych skryptowanych momentów. Czasem scena nigdy się nie kończy. To może po cichu zablokować kolejne sceny - zadanie, które nie idzie dalej, bez błędu, bez awarii. Ten mod pilnuje sceny, w której jesteś, ostrzega, jeśli siedzisz w niej już jakiś czas, pokazuje, co to jest, i pozwala ją zatrzymać, gdy się zacina.

**W skrócie:** zostaw domyślne ustawienia i graj dalej. Gdy dostaniesz alert, otwórz **Menu konfiguracji modów > It Just Works**.

Nie edytuje rekordów innych modów ani nie wymaga patchy, więc pozycja w kolejności wczytywania względem twojego stosu treści nie ma znaczenia. Nie zmieni sceny, dopóki mu nie każesz jej zatrzymać.

Wymaga **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** oraz **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (z `Load EditorIDs = true`, jeśli chcesz nazw zamiast numerów ID). Uwagi instalacyjne są na [stronie moda](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pięć stron: **Scena**, **Strażnik**, **Ustawienia**, **Diagnostyka**, **Odinstaluj**.

---

## Scena

### W czym jesteś

Odczyt bieżącej sceny albo **Brak**. Menu odświeża się przy otwarciu.

- **Czas w scenie** - w przybliżeniu, jak długo jesteś w tej scenie w tej sesji (czas rzeczywisty).
- **Scena** - nazwa, gdy dostępna; w przeciwnym razie numer ID.
- **Form ID** - surowy ID, zawsze widoczny. Przydatny w konsoli albo w zgłoszeniu błędu.
- **Zadanie nadrzędne** - do którego zadania należy ta scena.

### Zatrzymaj scenę

Jeśli uważasz, że scena się zacięła, to ją kończy.

1. Naciśnij **Zatrzymaj scenę** raz - wiersz potwierdza, że jest uzbrojona.
2. Naciśnij ponownie, by anulować, albo zamknij menu, by zatrzymać.

Zatrzymuj tylko scenę, którą uważasz za zaciętą. Zatrzymanie normalnej może coś zepsuć. Zatrzymanie zaciętej może (rzadko) wywołać krótką salwę opóźnionych zdarzeń, gdy gra nadrabia zaległości.

**Odśwież** ponownie odczytuje bieżącą scenę bez zamykania menu. W czystym Skyrimie odświeżanie raczej się nie przyda, bo gra pauzuje w menu. Jeśli używasz moda znoszącego pauzę, takiego jak [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), pozwala to odświeżyć bez ponownego otwierania menu.

### Ostatnie sceny

Ostatnie dziesięć scen, najnowsza pierwsza, z przybliżonym czasem trwania.

---

## Strażnik

Pilnuje, żebyś ty nie musiał.

- **Ostrzeż po** - jak długo scena może trwać, zanim dostaniesz alert. Domyślnie **6** minut. **0** = nigdy.  
  Nic w grze nie oznacza sceny jako zaciętej i nic w grze nie mówi nam, jak długo scena powinna trwać. Więc ustawiamy próg i ostrzegamy cię. Łączymy czas gry i czas rzeczywisty w sposób, który - mamy nadzieję - w przybliżeniu odzwierciedla „czas rzeczywiście spędzony na graniu", żeby ta kontrolka była intuicyjna.
- **Sprawdzaj co** - sekundy między sprawdzeniami. Domyślnie **30**. **0** = wyłącza strażnika.
- **Powtarzaj alerty** - domyślnie wyłączone, więc dostajesz jeden alert na scenę. Włącz, by alert powtarzał się, dopóki wciąż przekraczasz próg.
- **Powtarzaj co** - minuty między alertami, używane tylko gdy powtarzanie alertów jest włączone. Domyślnie **5**.

Alert to dwa wiersze w rogu, na przykład:

> scena blokuje inne ~6m  
> See? It Just Works!

Domyślnie jeden alert na scenę, dopóki jej nie opuścisz albo scena się nie zmieni. Przegapiłeś go? Otwórz menu - odczyt nadal pokazuje, w czym jesteś i jak długo. Mod nie zatrzymuje sceny za ciebie; służy do tego Zatrzymaj scenę na stronie Scena.

Strażnik zachowuje się tak samo niezależnie od tego, czy twoje menu pauzuje świat (wanilia), czy pozwala mu działać dalej (konfiguracje znoszące pauzę, takie jak [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) - alert nadal oznacza tylko tyle, że scena trwa już jakiś czas.

---

## Ustawienia

- **Włączony** - domyślnie włączony. Wyłącz, by odłożyć moda na bok bez odinstalowania.
- **Lekkość** - domyślnie włączone. Powiadomienia zachowują lekki ton; wyłącz, by uzyskać zwykłe brzmienie. Zmienia się tylko tekst, nigdy działanie moda.
- **Język powiadomień** - język własnych powiadomień moda w rogu ekranu. Instalator może go ustawić, gdy wybierzesz domyślny język menu; zmienisz go w każdej chwili na tej stronie. Domyślnie i zapasowo angielski; niezależny od ustawienia języka gry.
- **Nazwij bieżącą scenę** - przypisz klawisz; naciśnij go, by zobaczyć nazwę bieżącej sceny bez otwierania menu.
- **Wyczyść klawisz** - usuwa przypisanie.
- **Log diagnostyczny** - ile trafia do logu Papyrus. Zostaw **Wyłączony** przy normalnej grze. Użyj **Zdarzenia** przy zgłaszaniu błędu; **Każde sprawdzenie** tylko wtedy, gdy tropisz problem z timingiem, a potem wyłącz z powrotem. Może wpływać na wydajność, zwłaszcza przy każdym sprawdzeniu.

  Logowanie działa tylko wtedy, gdy gra zapisuje logi Papyrus. W `Documents\My Games\Skyrim Special Edition\` edytuj `Skyrim.ini` lub `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Zrestartuj. Plik logu: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Szukaj `fth_IJW`.

---

## Diagnostyka

- **Editor ID wczytane** - wskaźnik. Nazwy na stronie Scena i zadanie nadrzędne, gdy świeci; numery ID, gdy zgaszony. Form ID i tak zawsze pozostaje surowym `0x…`.

- **Strażnik** - czy sprawdzanie w tle działa:
  - **Działa** - w porządku
  - **Budzi się** - normalne zaraz po przeładowaniu
  - **Opóźniony** - nadal działa, ale sprawdzenia są wolniejsze niż zwykle (zajęta gra)
  - **Wyłączony** - ustawiłeś sprawdzaj co na 0
  - **Uśpiony** - włączony jest wyłączony w Ustawieniach

- **Ostatnia samonaprawa** - mod czasem poprawia własną księgowość (często po przeładowaniu). Wiersz tutaj jest normalny.

- **Wersja**

---

## Rozwiązywanie problemów

### Sceny wyświetlają się jako numery ID, a nie nazwy

po3 Tweaks nie wczytuje Editor ID. W `po3_Tweaks.ini` ustaw `Load EditorIDs = true` i zrestartuj Skyrim; wskaźnik **Editor ID wczytane** na stronie Diagnostyka to potwierdza. Menedżery modów mogą nadpisać ten plik przy wdrażaniu lub aktualizacji, więc edytuj kopię *wewnątrz* moda Tweaks (albo mały mod override, który wygrywa), a nie tylko luźny plik w `Data`:

- **MO2:** folder moda Tweaks w lewym panelu albo Overwrite / mod o wyższym priorytecie.
- **Vortex:** folder staging Tweaks albo mod override. Sprawdzaj ponownie po każdej aktualizacji.

Form ID i tak się wyświetla, więc nigdy nie zostajesz całkiem po ciemku.

### Powiadomienia są w niewłaściwym języku

Powiadomienia w rogu podążają za **Ustawienia > Język powiadomień**, a nie za językiem gry ani za tym, który plik tłumaczenia menu jest zainstalowany. Angielski jest domyślny i zapasowy.

Zwykłe uruchomienie instalatora, które ustawia domyślny język menu, ustawia też tę kontrolkę, żeby menu i powiadomienia się zgadzały. Jeśli tylko podmieniłeś plik menu ręcznie albo zaktualizowałeś moda bez ponownego wykonania tego kroku instalatora, ustaw język powiadomień raz, by pasował do twojego menu.

### Menu jest w niewłaściwym języku

Menu MCM podąża za ustawieniem języka gry, a nie za językiem powiadomień powyżej. Skyrim wczytuje plik tłumaczenia pasujący do języka gry, więc angielska gra pokazuje angielskie menu, nawet jeśli zainstalowałeś inny język. Dwa sposoby, by to zmienić:

- **Instalator:** zaznacz swój język w kroku 1, potem wybierz go jako domyślny język menu w kroku 2. To nadpisuje angielski plik menu (i zachowuje angielski `.bak`) **oraz** ustawia język powiadomień, by pasował.
- **Ręcznie:** zmień nazwę `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` na `fth_ItJustWorks_ENGLISH.txt`, zastępując angielski plik. To **nie** zmienia języka powiadomień - ustaw go w Ustawieniach, by pasował, bo inaczej powiadomienia zostaną po angielsku.

### Menu lub powiadomienia pokazują nieczytelne albo zniekształcone znaki

Tekst jest poprawny - twoja gra po prostu nie ma czcionki zdolnej narysować tych znaków, więc wyświetla się jako bełkot. Standardowa czcionka Skyrima obejmuje litery łacińskie i zachodnioeuropejskie, ale nie cyrylicę, chiński, japoński ani niektóre znaki środkowoeuropejskie. Jeśli używasz menu lub powiadomień w jednym z tych języków, zainstaluj moda z czcionką, który je zawiera; większość nieangielskich konfiguracji już go ma. Jeśli twoja nie, przeszukaj Nexus w poszukiwaniu czcionki obejmującej twój język - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) to szeroki punkt wyjścia.

### Żaden alert się nie pojawia

Sprawdź status Strażnika na stronie Diagnostyka, potem pokrętła Strażnika:

- Status **Uśpiony** - mod jest wyłączony. Włącz opcję Włączony (Ustawienia).
- Status **Wyłączony** - sprawdzaj co jest ustawione na 0. Ustaw je z powrotem na 10-240s.
- Ostrzeż po jest na **0** - to wyłącza alert. Ustaw liczbę minut, jaką chcesz.

Alert korzysta z czasu w taki sam sposób jak ostrzeż po, więc czas w scenie może czasem pokazywać wysoką wartość bez wywołania alertu - to normalne. To czas rzeczywisty i zeruje się po przeładowaniu. Nawet bez powiadomienia menu zawsze pokazuje bieżącą scenę i jak długo w niej jesteś.

### Zatrzymanie sceny nie usunęło sceny

Zatrzymanie ani razu nie zawiodło przez ponad 10 lat odblokowywania zapisów - najpierw prowizorycznymi, jednorazowymi wersjami, a teraz tym modem. Więc jeśli kiedykolwiek zgłosi, że scena się nie zakończyła, to albo znalazłeś błąd w modzie, albo coś naprawdę nowego. To ekscytujące. Zaskoczenie to miejsce, gdzie rodzi się nauka. Kompletny log to najlepsza szansa, by to wytropić. Włącz logowanie Papyrus, ustaw log diagnostyczny na **Każde sprawdzenie** i włącz każdą opcję logowania lub debugowania, jaką znajdziesz w całej swojej kolejności wczytywania, tak by - jeśli zdarzy się ponownie - zostało to uchwycone. Potem wyślij kompletny `Papyrus.0.log` jako zgłoszenie błędu. Przeładuj sprzed zacięcia, żeby grać dalej w międzyczasie.

### Zgłaszanie błędu albo prośba o pomoc

Przy błędzie ustaw log diagnostyczny na **Zdarzenia**, odtwórz problem, potem wyjdź z gry. Z włączonym logowaniem Papyrus (wiersze `Skyrim.ini` są opisane w Ustawieniach), otwórz `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` i szukaj `fth_IJW`. Dołącz to, form ID sceny i zadanie nadrzędne oraz to, co robiłeś, gdy się zacięła.

Gdzie to wysłać:

- **Zgłoszenia błędów:** [zakładka Bugs](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) na stronie moda albo [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Pytania i ogólna pomoc:** [zakładka Posts](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) na stronie moda.

---

## Odinstaluj

**Usuń go na dobre:**

1. Na stronie Ustawienia wyłącz opcję Włączony.
2. Zapisz, wyjdź na pulpit.
3. Usuń moda w swoim menedżerze (lub ręcznie).

Bezpieczne do usunięcia w trakcie rozgrywki. Skyrim może zostawić w zapisie mały, martwy stub skryptu, jak inne skryptowane mody; gra go ignoruje. Opcjonalnie: cleaner zapisu (np. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** w FallrimTools) może usunąć stuby po usunięciu moda - używaj cleanerów ostrożnie, tylko na to, co zamierzasz usunąć. Możesz zostawić tego moda zainstalowanego, czyszcząc śmieci z *innych* modów.
