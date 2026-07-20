# Korzystanie z It Just Works™

Wszystkim, co robi mod, sterujesz z jednej strony: **Menu Konfiguracji Modów > It Just Works**. Oto co robi każda część.

Wersja krótka, jeśli dopiero go zainstalowałeś: zostaw ustawienia domyślne w spokoju, graj dalej i pozwól, by strażnik klepnął cię w ramię, jeśli kiedyś utkniesz w jednej scenie zbyt długo. Wszystko poniżej jest na chwile, gdy zechcesz przyjrzeć się bliżej.

## Wyświetlanie menu po polsku

Mod zawiera tłumaczenia menu dla kilku języków - wybierz je w instalatorze. Skyrim wczytuje tłumaczenie zgodne z **ustawieniem języka** twojej gry; więc jeśli gra działa po angielsku, a chcesz menu w innym języku, wciąż czyta plik angielski i menu pozostaje angielskie, mimo że tłumaczenie jest zainstalowane. Dwa rozwiązania: w instalatorze ustaw polski jako **domyślny język menu** (zapisze tłumaczenie na pliku angielskim za ciebie); albo ręcznie zmień nazwę swojego pliku językowego w `Interface\Translations\` - `fth_ItJustWorks_POLISH.txt` - na `fth_ItJustWorks_ENGLISH.txt`, zastępując angielski.

## Bieżąca scena

Góra strony to podgląd na żywo sceny, w której właśnie jesteś, albo "None", jeśli w żadnej nie jesteś. Otwarcie strony pobiera świeży odczyt, więc nigdy nie jest nieaktualny.

- **Scena** - scena, w której jesteś, po nazwie (jej Editor ID), gdy nazwy są dostępne, albo surowy numer ID, gdy nie są (patrz kontrolka poniżej).
- **Form ID** - surowy numer ID sceny, zawsze widoczny, na wypadek gdybyś potrzebował go do konsoli albo zgłoszenia błędu.
- **Zadanie nadrzędne** - zadanie, do którego należy scena. Zwykle bardziej przydatna nazwa: mówi ci, *co* cię trzyma.
- **Czas w scenie** - mniej więcej jak długo jesteś w tej scenie. Oznaczone znakiem `~`, bo mod sprawdza według czasomierza, więc zna odpowiedź z dokładnością do jednego sprawdzenia.

## Kontrolka "Editor ID wczytane"

Kontrolka stanu, nie przełącznik - kliknięcie nie robi nic poza przywróceniem jej do prawdy.

- **Świeci** - dobrze. powerofthree's Tweaks wczytuje Editor ID, więc sceny i zadania pokazują się po nazwie.
- **Zgaszona** - nazwy są wyłączone; wszystko pokazuje się zamiast tego jako numery ID. Mod działa dokładnie tak samo w obu przypadkach - po prostu trudniej to czytać.

Aby włączyć nazwy: otwórz `po3_Tweaks.ini` (w instalacji powerofthree's Tweaks) i ustaw `Load EditorIDs = true`, a potem uruchom Skyrim ponownie. Kontrolka się zapala i nazwy się pojawiają.

Mod mówi o tym także raz, sam z siebie, gdy po raz pierwszy zauważy, że nazwy są wyłączone. Ta kontrolka to trwała wersja tego powiadomienia - to, na co wskazać w wątku pomocy, gdy ktoś pyta, czemu jego sceny to same numery.

## Akcje

- **Zatrzymaj scenę** - rozwiązanie. Jeśli naprawdę utknąłeś, to kończy scenę, w której jesteś. Celowo jest dwuetapowe: naciśnij **Zatrzymaj scenę** raz, aby uzbroić (pojawia się wiersz potwierdzający, że zatrzyma się po zamknięciu menu), i naciśnij ponownie, aby anulować. Samo zatrzymanie następuje w chwili zamknięcia menu, bo tylko wtedy gra działa na tyle, by zadziałało. Czyli: uzbrój, zamknij menu, gotowe.

  Sięgaj po to tylko, jeśli sądzisz, że scena jest zablokowana. Zatrzymanie sceny, która działa normalnie, może coś zepsuć, a zatrzymanie zablokowanej może wywołać krótki nawał opóźnionych zdarzeń, gdy gra nadrabia zaległości - to normalne, nie nowy błąd.

- **Odśwież** - pobiera świeży odczyt bieżącej sceny natychmiast, bez zamykania i ponownego otwierania strony.

## Ostatnie sceny

Ostatnie dziesięć scen, przez które przeszedłeś, od najnowszej, każda z przybliżonym czasem trwania. Przydatne przy "zaraz, co to było przed chwilą", zwłaszcza gdy scena mignie za szybko, by ją uchwycić.

## Strażnik

Część, która czuwa, żebyś ty nie musiał.

- **Ostrzeż po** - po ilu minutach w jednej scenie mod ma cię ostrzec. Domyślnie 3. Ustaw 0, aby nigdy nie ostrzegać.
- **Sprawdzaj co** - jak często strażnik zagląda, w sekundach. Domyślnie 30. Ustaw 0, aby całkowicie wyłączyć strażnika. Jest to pomyślane pod przypadek zauważony dużo później, więc nie musi być szybkie: od 10 do 240 sekund w zupełności wystarczy i jest lżejsze dla gry.
- **Zapisuj do Papyrus** - zapisuje każdą zmianę sceny do logu Papyrus. Zostaw wyłączone, chyba że diagnozujesz problem albo wypełniasz zgłoszenie błędu.

Gdy strażnik zadziała, to dwie krótkie linijki w rogu - jak długo jesteś w scenie i że blokuje inne, potem nazwa moda. Nie musisz mieć otwartego menu, aby to zobaczyć.

## Ustawienia

- **Nazwij bieżącą scenę** - przypisz tu klawisz, a jego naciśnięcie wyświetli nazwę sceny, w której właśnie jesteś, w ogóle bez otwierania menu. Najszybsze "w czym ja teraz jestem".
- **Wyczyść klawisz** - odpina ten klawisz. Nie ma tu czyszczenia przez ESC (w tym menu ESC to Pauza, a gra ostrzega cię o konflikcie), więc to tym przyciskiem zdejmujesz przypisanie, gdy już jakiś ustawiłeś.

## O modzie

Wersja, żebyś od razu widział, którą kompilację grasz - przydatne, gdy prosisz o pomoc albo sprawdzasz, czy masz aktualną.

## Wyłączanie lub usuwanie

Nie musisz odinstalowywać moda, żeby przestał działać. Strona **Odinstaluj** ma jeden przełącznik **Włączony**: wyłącz go, a mod przechodzi w uśpienie - strażnik przestaje sprawdzać, a klawisz się wyrejestrowuje - bez czyszczenia czegokolwiek i bez ruszania twojego zapisu. Włącz go z powrotem, kiedy tylko zechcesz, a podejmie działanie dokładnie tam, gdzie skończył. To łagodny sposób, by odłożyć go w trakcie rozgrywki, i łatwy sposób, by sprawdzić, czy to on w ogóle był tym, co ci przeszkadzało.

Jeśli jednak chcesz się go pozbyć na dobre, usuń go w tej kolejności:

1. **Wyłącz go** na stronie Odinstaluj.
2. **Zapisz grę, potem wyjdź** na pulpit.
3. **Usuń mod** w swoim menedżerze modów (Vortex, MO2 albo ręcznie).

To naprawdę wszystko, czego trzeba. Nic, co robi ten mod, nie zepsuje zapisu przy wyjściu - nie przetrzymuje żadnych obiektów gry, niczego nie blokuje i nic innego od niego nie zależy. To, co po sobie zostawia, zostawia *każdy* skryptowy mod: mały, bezczynny ślad w zapisie, tam gdzie mieszkał jego skrypt. Skyrim go ignoruje. Jeśli chcesz, by zniknął nawet on, możesz wymieść ten ślad narzędziem do czyszczenia zapisów, gdy mod już zostanie usunięty.

### O czyszczeniu zapisów (ReSaver)

Przy długim zapisie od czasu do czasu uruchomisz czyszczenie - zwykle jest to **ReSaver** (część FallrimTools) - by usunąć skryptowy osad zostawiony przez *inne* mody, które podmieniłeś albo usunąłeś. Możesz przy tym zostawić It Just Works zainstalowany. Jest zbudowany tak, by przetrwać czyszczenie: bez aliasów, bez stanu świata, samonaprawiający się. Normalne przejście go nie ruszy, a nawet agresywne, które wyczyści jego czasomierz sprawdzania albo klawisz, uzbroi się z powrotem, gdy następnym razem otworzysz menu. Ryzyko dla *tego* moda jest z założenia mniej więcej tak niskie, jak tylko może być u skryptowego moda.

Zastrzeżenia, które pozostają, dotyczą narzędzia, nie nas: wiedz, co robi ReSaver, zanim wycelujesz nim w zapis, na którym ci zależy, i bierz na cel to, co faktycznie usunąłeś, zamiast ślepego zamiatania.
