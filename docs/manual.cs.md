# Používání It Just Works™

## Co dělá a proč

Skyrim stojí na *scénách* - skriptovaných okamžicích jako rozhovory a filmové sekvence, které mají skončit samy od sebe. Někdy jedna neskončí, a zaseknutá scéna může tiše zablokovat ty, které přijdou po ní, a nenápadně tak rozbít úkol, nebo i celý save, aniž by tě varovala jakákoli chyba. Tento mod hlídá scénu, ve které právě jsi, a upozorní tě, když v jedné uvízneš příliš dlouho, ukáže ti z menu, v čem právě jsi, a nechá tě zastavit scénu, která se zasekla. O to celé jde: zachytit zaseknutý přepínač dřív, než tě to bude stát save.

Vše, co mod dělá, ovládáš z jediné stránky: **Menu konfigurace modů > It Just Works**. Zde je, co která část dělá.

Krátká verze, pokud jsi ho právě nainstaloval: nech výchozí hodnoty být, hraj dál a nech hlídače, ať tě ťukne do ramene, kdybys někdy uvízl v jedné scéně příliš dlouho. Vše níže je pro chvíle, kdy se chceš podívat blíž.

## Zobrazení menu v češtině

Mod obsahuje překlady menu pro několik jazyků - vyber si je v instalátoru. Skyrim načítá překlad odpovídající **nastavení jazyka** tvé hry; takže pokud hra běží v angličtině, ale chceš menu v jiném jazyce, dál čte anglický soubor a menu zůstává anglické, přestože je překlad nainstalovaný. Dvě řešení: v instalátoru zaškrtni ten jazyk v prvním kroku a pak si ho ve druhém zvol jako svůj **výchozí jazyk menu** (zapíše překlad přes anglický soubor za tebe a ponechá anglický `.bak`, který můžeš přejmenovat zpátky); nebo ručně přejmenuj svůj jazykový soubor v `Interface\Translations\` - `fth_ItJustWorks_CZECH.txt` - na `fth_ItJustWorks_ENGLISH.txt` a nahraď tím anglický.

## Aktuální scéna

Horní část stránky je živý výpis scény, ve které právě jsi, nebo "None", pokud v žádné nejsi. Otevření stránky provede čerstvé načtení, takže nikdy není zastaralá.

- **Scéna** - scéna, ve které jsi, podle názvu (její Editor ID), když jsou názvy dostupné, jinak holé číslo ID (viz kontrolka níže).
- **Form ID** - holé číslo ID scény, vždy zobrazené, pro případ, že bys ho potřeboval do konzole nebo do hlášení chyby.
- **Nadřazený úkol** - úkol, kterému scéna patří. Obvykle užitečnější název: řekne ti, *co* tě drží.
- **Čas ve scéně** - přibližně jak dlouho už jsi v této scéně. Označeno znakem `~`, protože mod kontroluje podle časovače, takže odpověď zná s přesností na jednu kontrolu.

## Kontrolka "Editor ID načteny"

Stavová kontrolka, ne přepínač - kliknutí na ni neudělá nic, jen ji vrátí k pravdě.

- **Svítí** - dobře. powerofthree's Tweaks načítá Editor ID, takže scény a úkoly se zobrazují podle názvu.
- **Zhasnuto** - názvy jsou vypnuté; vše se místo toho zobrazuje jako čísla ID. Mod funguje úplně stejně tak či tak - jen se to hůř čte.

Jak zapnout názvy: otevři `po3_Tweaks.ini` (v instalaci powerofthree's Tweaks) a nastav `Load EditorIDs = true`, poté restartuj Skyrim. Kontrolka se rozsvítí a názvy se objeví.

Mod to také jednou sám oznámí, když poprvé zjistí, že názvy jsou vypnuté. Tato kontrolka je trvalá podoba onoho oznámení - to, na co ukázat ve vlákně pomoci, když se někdo ptá, proč jsou jeho scény samá čísla.

## Akce

- **Zastavit scénu** - náprava. Pokud jsi opravdu zaseknutý, tohle ukončí scénu, ve které jsi. Je to záměrně na dva kroky: stiskni **Zastavit scénu** jednou pro připravení (objeví se řádek potvrzující, že se zastaví při zavření menu), a stiskni znovu pro zrušení. Samotné zastavení nastane ve chvíli, kdy zavřeš menu, protože jen tehdy hra běží dost na to, aby se projevilo. Takže: připrav, zavři menu, hotovo.

  Sáhni po tom jen, pokud věříš, že je scéna zaseknutá. Zastavení scény, která normálně funguje, může něco rozbít, a zastavení zaseknuté může spustit krátký nával odložených událostí, jak hra dohání skluz - to se očekává, není to nová chyba.

- **Obnovit** - provede čerstvé načtení aktuální scény hned teď, bez zavírání a znovuotevírání stránky.

## Nedávné scény

Posledních deset scén, kterými jsi prošel, nejnovější první, každá s přibližnou dobou trvání. Užitečné pro "počkat, co to bylo před chvílí", zvlášť když scéna proletí příliš rychle, než abys ji zachytil.

## Hlídač

Ta část, která hlídá, abys nemusel ty.

- **Upozornit po** - po kolika minutách v jedné scéně tě mod upozorní. Výchozí je 3. Nastav 0, aby neupozorňoval nikdy.
- **Kontrolovat každých** - jak často se hlídač dívá, v sekundách. Výchozí je 30. Nastav 0, aby ses hlídače úplně zbavil. Je to určeno pro případ, který si všimneš až mnohem později, takže nemusí být rychlé: cokoli mezi 10 a 240 sekundami bohatě stačí a je to šetrnější k tvé hře.

Když hlídač spustí, jsou to dva krátké řádky v rohu - jak dlouho jsi ve scéně a že blokuje ostatní, pak název modu. Nemusíš mít otevřené menu, abys to viděl.

## Sledování při práci (stránka Diagnostika)

- **Hlídač** - jedno slovo pro to, zda kontrola na pozadí právě běží: **Běží**, **Probouzí se** (na okamžik hned po načtení normální), **Vypnuto** (nastavil jsi Kontrolovat každých na 0) nebo **Uspáno** (vypnuto na stránce Odinstalovat). Takto ověříš, že mod žije, aniž bys otevíral log.
- **Poslední samooprava** - mod čas od času tiše sesynchronizuje svůj vlastní stav, nejčastěji hned po načtení - například znovu sesynchronizuje časovač scény, aby scéna, ve které jsi uvízl přes načtení, přesto byla zachycena. Řádek zde je normální, zdravá údržba (nástroj ti říká, že se sám opravil), ne chyba.
- **Diagnostický log** - kolik toho mod zapisuje do logu Papyrus, pro řešení potíží nebo hlášení chyby:
  - **Vypnuto** - nic. Výchozí; nech to tak pro běžné hraní.
  - **Události** - změny scén, upozornění a pokaždé, když se mod sám opraví. Nastav pro vyplnění hlášení chyby.
  - **Každá kontrola** - přidá řádek při každém dotazu (tep smyčky, stoupající časovač). Pro dohledání problému s časováním, pak vrať zpět.

Log se dostane na disk, jen pokud je v hře zapnuté logování Papyrus. Přidej blok `[Papyrus]` do `Skyrim.ini` (nebo `SkyrimCustom.ini`) v `Documents\My Games\Skyrim Special Edition\`:

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Restartuj Skyrim. Soubor přistane v `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`; hledej v něm `fth_IJW` (`findstr fth_IJW Papyrus.0.log`, nebo `grep`). S Mod Organizer 2 je to tvá skutečná složka Documents, ne virtuální herní složka.

## Nastavení

- **Pojmenovat aktuální scénu** - přiřaď zde klávesu, a její stisk zobrazí název scény, ve které právě jsi, aniž bys menu vůbec otevíral. Nejrychlejší "v čem to zrovna jsem".
- **Zrušit klávesu** - odebere přiřazenou klávesu. Není zde žádné rušení přes ESC (v tomto menu je ESC Pauza a hra tě na ten konflikt upozorní), takže jakmile jednou klávesu přiřadíš, tímto tlačítkem přiřazení zase sundáš.

## O modu

Verze, ať na první pohled vidíš, který build hraješ - hodí se, když žádáš o pomoc nebo kontroluješ, jestli jsi aktuální.

## Vypnutí nebo odstranění

Nemusíš mod odinstalovávat, aby přestal fungovat. Stránka **Odinstalovat** má jediný přepínač **Zapnuto**: vypni ho a mod usne - hlídač přestane kontrolovat a klávesa se odregistruje - aniž by se cokoli vyčistilo nebo se sáhlo na tvůj save. Kdykoli ho zase zapni a naváže přesně tam, kde skončil. To je šetrný způsob, jak ho odložit uprostřed hraní, a snadný způsob, jak ověřit, jestli to náhodou nebyl on, co ti dělal potíže.

Pokud ho chceš mít pryč nadobro, odstraň ho v tomto pořadí:

1. **Vypni ho** na stránce Odinstalovat.
2. **Ulož hru, pak ji ukonči** na plochu.
3. **Odeber mod** ve svém správci modů (Vortex, MO2, nebo ručně).

To je opravdu všechno, co je potřeba. Nic z toho, co tento mod dělá, ti při odchodu nerozbije save - nedrží žádné herní objekty jako rukojmí, nic neblokuje a nic jiného na něm nezávisí. Co po sobě zanechá, je to, co po sobě zanechá *každý* skriptovaný mod: malý, netečný pahýl v savu na místě, kde dřív žil jeho skript. Skyrim si ho nevšímá. Pokud chceš pryč i ten, můžeš pahýl vymést čističem savů, jakmile je mod odebraný.

### O čističích savů (ReSaver)

U dlouhého savu občas spustíš čistič - **ReSaver** (součást FallrimTools) je ten obvyklý - abys pročistil skriptové zbytky po *jiných* modech, které jsi vyměnil nebo odebral. It Just Works můžeš přitom nechat nainstalovaný. Je stavěný tak, aby čištění přežil: bez aliasů, bez stavu světa, samoopravný. Běžný průchod se ho nedotkne, a i ten agresivní, co mu vymaže časovač kontroly nebo klávesu, se znovu nastartuje, jakmile příště otevřeš menu. Riziko pro *tento* mod je tak nízké, jak u skriptovaného modu jen může být, záměrně.

Varování, která zůstávají, se týkají toho nástroje, ne nás: věz, co ReSaver dělá, než ho namíříš na save, který máš rád, a miř na to, co jsi opravdu odebral, místo slepého vymetání.
