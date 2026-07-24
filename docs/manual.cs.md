# Jak používat It Just Works™

## Co dělá

Skyrim používá *scény* pro rozhovory, cutscény a další skriptované momenty. Někdy scéna nikdy neskončí. To může tiše zablokovat pozdější scény - quest, který se nehne, bez chyby a bez pádu. Tento mod sleduje scénu, ve které jste, upozorní vás, pokud jste v jedné příliš dlouho, ukáže vám, která to je, a nechá vás ji zastavit, pokud se zasekla.

**Stručně:** nechte výchozí hodnoty zapnuté a hrajte dál. Když přijde upozornění, otevřete **Menu konfigurace modů > It Just Works**.

Potřebuje **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** a **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (s `Load EditorIDs = true`, pokud chcete jména místo čísel ID). Poznámky k instalaci jsou na [stránce modu](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pět stránek: **Scéna**, **Hlídač**, **Nastavení**, **Diagnostika**, **Odinstalovat**.

---

## Scéna

### V čem jste

Živý výpis aktuální scény, nebo **None**. Otevřete menu pro čerstvé čtení.

- **Čas ve scéně** - zhruba jak dlouho jste v této scéně; načtení hry ho vynuluje. To je signál zaseknutí.
- **Scéna** - jméno, když jsou jména k dispozici; jinak číslo ID.
- **Form ID** - surové ID, vždy zobrazené. Hodí se pro konzoli nebo hlášení chyby.
- **Nadřazený úkol** - ke kterému questu scéna patří.

### Zastavit scénu

Pokud věříte, že scéna je zaseknutá, tím ji ukončíte.

1. Stiskněte **Zastavit scénu** jednou - řádek potvrdí, že je nabitá.
2. Stiskněte znovu pro zrušení, nebo **zavřete menu** pro zastavení.

Zastavujte jen scénu, kterou považujete za zaseknutou. Zastavení normální může něco rozbít. Zastavení zaseknuté může (vzácně) spustit krátkou vlnu zpožděných událostí, než hra dožene.

**Obnovit** znovu načte aktuální scénu bez zavírání menu. Ve vanilla Skyrimu je hra v menu obvykle pozastavená, takže **Obnovit** pravděpodobně nebude užitečné. Pokud používáte mod pro zrušení pauzy jako [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), umožňuje vám to obnovit menu bez jeho opětovného otevření.

### Nedávné scény

Posledních deset scén, nejnovější první, s hrubou délkou. Stejný druh přibližného času jako výše.

---

## Hlídač

Hlídá, abyste nemuseli.

- **Upozornit po** - minuty v jedné scéně před upozorněním. Výchozí **3**. **0** = nikdy neupozorňovat.
- **Kontrolovat každých** - sekundy mezi kontrolami. Výchozí **30**. **0** = hlídač vypnout.

Upozornění jsou dva řádky v rohu, například:

> scene blocking others ~3m  
> See? It Just Works!

Jednou na scénu, dokud ji neopustíte nebo se scéna nezmění. Minuli jste toast? Otevřete menu - výpis pořád ukazuje, v čem jste a jak dlouho. Mod scénu sám nezastaví; na to je **Zastavit scénu**.

---

## Nastavení

- **Zapnuto** - ve výchozím stavu zapnuto. Vypnutím mod odložíte bez odinstalace.
- **Lehkost** - ve výchozím stavu zapnuto. Oznámení si drží lehčí tón; vypnutím získáte prostý text. Mění se jen text, nikdy fungování modu.
- **Jazyk oznámení** - jazyk vlastních vyskakovacích oznámení modu (toastů v rohu). Nastavte ho podle jazyka svého menu. Ve výchozím stavu angličtina; nezávislý na nastavení jazyka hry.
- **Pojmenovat aktuální scénu** - přiřaďte klávesu; stiskněte ji a uvidíte jméno aktuální scény bez otevírání menu.
- **Zrušit klávesu** - odstraní vazbu.
- **Diagnostický log** - kolik jde do Papyrus logu. Pro běžné hraní nechte **Vypnuto**. **Události** při hlášení chyby; **Každá kontrola** jen když stíháte timing problém, pak ho zase vypněte. Může ovlivnit výkon, zvlášť při **Každá kontrola**.

  Logování funguje jen tehdy, když hra zapisuje Papyrus logy. V `Documents\My Games\Skyrim Special Edition\` upravte `Skyrim.ini` nebo `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restartujte. Soubor logu: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Hledejte `fth_IJW`.

---

## Diagnostika

- **Editor ID načteny** - indikátor. Jména na **Scéna** a nadřazeném úkolu, když svítí; čísla ID, když je zhasnutá. **Form ID** je stále surové `0x…` v obou případech.

- **Hlídač** - zda běží kontrola na pozadí:
  - **Běží** - v pořádku
  - **Probouzí se** - normální hned po načtení
  - **Opožděno** - stále pracuje, ale kontroly jdou pomaleji než obvykle (vytížená hra)
  - **Vypnuto (kontroly zakázány)** - nastavili jste **Kontrolovat každých** na 0
  - **Uspáno (vypnuto)** - **Zapnuto** je vypnuté na stránce **Nastavení**

- **Poslední samooprava** - mod občas opraví vlastní účetnictví (často po načtení). Řádek tady je normální.

- **Verze**

---

## Řešení potíží

### Scény se zobrazují jako čísla ID, ne jména

po3 Tweaks nenačítá Editor ID. V `po3_Tweaks.ini` nastavte `Load EditorIDs = true` a restartujte Skyrim; kontrolka *Editor ID načteny* na stránce **Diagnostika** to potvrdí. Správci modů mohou tento soubor při nasazení nebo aktualizaci přepsat, takže upravte kopii *uvnitř* modu Tweaks (nebo malý override mod, který vyhraje), ne jen volný soubor v `Data`:

- **MO2:** složka modu Tweaks v levém panelu, nebo Overwrite / mod s vyšší prioritou.
- **Vortex:** staging složka Tweaks, nebo override mod. Po každé aktualizaci znovu zkontrolujte.

**Form ID** se zobrazí tak jako tak, takže nikdy nejste úplně v temnotě.

### Oznámení jsou ve špatném jazyce

Mod má dvě nezávislá nastavení jazyka; toto je to pro jeho vlastní vyskakovací oznámení. Nastavte **Nastavení > Jazyk oznámení** na svůj jazyk - ovládá toasty v rohu (upozornění na zaseknutou scénu, nápovědu se jmény, výsledky zastavení). Je nezávislé na jazyce hry i na jazyce menu níže. Angličtina je výchozí a záložní, takže nepřeložený řádek se zobrazí anglicky, místo aby se rozbil.

### Menu je ve špatném jazyce

Menu MCM se řídí **nastavením jazyka** hry, ne jazykem oznámení výše. Skyrim načte překladový soubor, který odpovídá jazyku hry, takže anglická hra ukáže anglické menu, i když jste nainstalovali jiný jazyk. Změnit to jde dvěma způsoby:

- **Instalátor:** zaškrtněte svůj jazyk v kroku 1, pak ho v kroku 2 zvolte jako výchozí jazyk menu (zapíše přes anglický soubor a ponechá anglický `.bak`).
- **Ručně:** přejmenujte `Interface\Translations\fth_ItJustWorks_CZECH.txt` na `fth_ItJustWorks_ENGLISH.txt` a nahraďte anglický soubor.

### Menu nebo oznámení zobrazují zkomolené či nečitelné znaky

Text je správně - vaše hra jen nemá žádné písmo, které by tyto znaky dokázalo vykreslit, takže se zobrazí jako guláš. Výchozí písmo Skyrimu pokrývá latinku a západoevropská písmena, ale ne cyrilici, čínštinu, japonštinu ani některé středoevropské znaky. Pokud používáte menu nebo oznámení v některém z nich, nainstalujte **font mod**, který je obsahuje; většina neanglických sestav už nějaký má. Pokud ten váš ne, prohledejte Nexus a najděte písmo pokrývající váš jazyk - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) je široký výchozí bod.

### Žádné upozornění se nikdy neobjeví

Zkontrolujte stav **Hlídače** na stránce **Diagnostika**, pak číselníky **Hlídače**:

- Stav **Uspáno (vypnuto)** - mod je vypnutý. Zapněte **Zapnuto** (Nastavení).
- Stav **Vypnuto (kontroly zakázány)** - **Kontrolovat každých** je 0. Nastavte zpět na 10-240 s.
- **Upozornit po** je **0** - to vypíná upozornění. Nastavte počet minut, který chcete.

**Čas ve scéně** se při načtení vynuluje, takže scéna upozorní, až když jste v ní byli, nepřetržitě, déle než je čas upozornění v této relaci. I bez toastu menu vždy ukazuje aktuální scénu a jak dlouho v ní jste.

### Zastavit scénu scénu nevyčistilo

Zastavení dosud ani jednou neselhalo - za 14 let odseknávání savů, nejdřív s hrubými jednorázovými verzemi a teď s tímhle. Takže pokud někdy nahlásí, že scéna neskončila, našli jste něco opravdu nového - což je vzrušující, ne znepokojivé. Překvapení je místo, kde se člověk učí. Zatím není známá žádná příčina a nic se neslibuje, ale úplný log je nejlepší šance ji vypátrat. Zapněte Papyrus logování, nastavte **Nastavení > Diagnostický log** na **Každá kontrola** a zapněte každou možnost logu nebo ladění, kterou napříč svým load orderem najdete - aby to, pokud se to stane znovu, bylo zachyceno. Pak pošlete úplný `Papyrus.0.log` jako hlášení chyby (kanály níže). Mezitím se vraťte k načtení z doby před zaseknutím a hrajte dál.

### Podání hlášení chyby, nebo žádost o pomoc

U chyby nastavte **Nastavení > Diagnostický log** na **Události**, problém reprodukujte a pak ukončete. Se zapnutým Papyrus logováním (řádky `Skyrim.ini` jsou pod **Nastavení**) otevřete `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` a hledejte `fth_IJW`. Přiložte ho, **Form ID** scény a **Nadřazený úkol** a co jste dělali, když se to zaseklo.

Kam to poslat:

- **Hlášení chyb:** [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) na stránce modu, nebo [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Dotazy a obecná pomoc:** [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) na stránce modu.

---

## Odinstalovat

**Odstranit natrvalo:**

1. Na stránce **Nastavení** vypněte **Zapnuto**.
2. Uložte, ukončete na plochu.
3. Odstraňte mod ve správci (nebo ručně).

Bezpečné odstranit uprostřed průchodu. Skyrim může v save nechat malý inertní stub skriptu, jako jiné skriptované mody; hra ho ignoruje. Volitelně: cleaner save (např. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** ve FallrimTools) může stuby po odstranění vyčistit - cleanery používejte opatrně a jen na to, co jste opravdu chtěli odstranit. Tento mod můžete nechat nainstalovaný, zatímco čistíte odpad z *jiných* modů.
