# Jak používat It Just Works™

## Co dělá

Skyrim používá *scény* pro rozhovory, cutscény a další skriptované momenty. Někdy scéna nikdy neskončí. To může tiše zablokovat pozdější scény - quest, který se nehne, bez chyby a bez pádu. Tento mod sleduje scénu, ve které jste, upozorní vás, pokud jste v jedné byli už chvíli, ukáže vám, co to je, a nechá vás ji zastavit, pokud se zasekla.

**Stručně:** nechte výchozí hodnoty zapnuté a hrajte dál. Když přijde upozornění, otevřete **Menu konfigurace modů > It Just Works**.

Neupravuje záznamy jiných modů ani nepotřebuje patche, takže na pořadí v load orderu vůči vašemu obsahu nezáleží. Nezmění scénu, dokud mu to neřeknete.

Potřebuje **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** a **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (s `Load EditorIDs = true`, pokud chcete jména místo čísel ID). Poznámky k instalaci jsou na [stránce modu](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pět stránek: **Scéna**, **Hlídač**, **Nastavení**, **Diagnostika**, **Odinstalovat**.

---

## Scéna

### V čem jste

Výpis aktuální scény, nebo **Žádná**. Menu se při otevření obnoví.

- **Čas ve scéně** - zhruba jak dlouho jste v této scéně během této relace (reálný čas).
- **Scéna** - jméno, pokud je k dispozici; jinak číslo ID.
- **Form ID** - surové ID, vždy zobrazené. Hodí se pro konzoli nebo hlášení chyby.
- **Nadřazený úkol** - kterému questu ta scéna patří.

### Zastavit scénu

Pokud věříte, že scéna je zaseknutá, tímto ji ukončíte.

1. Stiskněte **Zastavit scénu** jednou - řádek potvrdí, že je nabitá.
2. Stiskněte znovu pro zrušení, nebo zavřete menu pro zastavení.

Zastavujte jen scénu, o které si myslíte, že je zaseknutá. Zastavení normální scény může něco rozbít. Zastavení zaseknuté může (vzácně) spustit krátkou vlnu zpožděných událostí, než to hra dožene.

**Obnovit** znovu načte aktuální scénu bez zavření menu. Ve vanilla Skyrimu Obnovit pravděpodobně nebude užitečné, protože hra se v menu pozastavuje. Pokud používáte mod pro zrušení pauzy jako [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), umožní vám to obnovit bez opětovného otevření menu.

### Nedávné scény

Posledních deset scén, nejnovější první, s přibližnou délkou.

---

## Hlídač

Hlídá, abyste nemuseli.

- **Upozornit po** - jak dlouho může scéna běžet, než přijde upozornění. Výchozí **6** minut. **0** = nikdy.  
  Nic ve hře neoznačuje scénu jako zaseknutou a nic ve hře neříká, jak dlouho má scéna běžet. Proto nastavíme prahovou hodnotu a upozorníme vás. Kombinujeme herní čas a reálný čas způsobem, který má podle nás zhruba odpovídat „reálnému času stráveného skutečným hraním", aby byl ovládací prvek intuitivní.
- **Kontrolovat každých** - sekundy mezi kontrolami. Výchozí **30**. **0** = hlídač vypnout.
- **Opakovat upozornění** - ve výchozím stavu vypnuto, takže dostanete jedno upozornění na scénu. Zapněte, pokud chcete dál dostávat upozornění, dokud jste nad prahovou hodnotou.
- **Opakovat každých** - minuty mezi upozorněními, použije se jen když je zapnuto opakování upozornění. Výchozí **5**.

Upozornění jsou dva řádky v rohu, například:

> scéna blokuje ostatní ~6m  
> See? It Just Works!

Ve výchozím stavu jedno upozornění na scénu, dokud ji neopustíte nebo se scéna nezmění. Minuli jste ho? Otevřete menu - výpis pořád ukazuje, v čem jste a jak dlouho. Mod scénu sám nezastaví; k tomu použijte Zastavit scénu na stránce Scéna.

Hlídač se chová stejně, ať už vaše menu svět pozastavují (vanilla), nebo ho nechávají běžet (sestavy pro zrušení pauzy jako [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) - upozornění pořád jen znamená, že scéna běží už chvíli.

---

## Nastavení

- **Zapnuto** - ve výchozím stavu zapnuto. Vypnutím mod odložíte bez odinstalace.
- **Lehkost** - ve výchozím stavu zapnuto. Oznámení si drží lehčí tón; vypnutím získáte prostý text. Mění se jen text, nikdy fungování modu.
- **Jazyk oznámení** - jazyk vlastních oznámení modu v rohu. Instalátor ho může předvyplnit, když zvolíte výchozí jazyk menu; kdykoli ho můžete změnit na této stránce. Ve výchozím stavu i jako záloha angličtina; nezávislý na nastavení jazyka hry.
- **Pojmenovat aktuální scénu** - přiřaďte klávesu; jejím stisknutím uvidíte jméno aktuální scény bez otevření menu.
- **Zrušit klávesu** - odstraní vazbu.
- **Diagnostický log** - kolik jde do Papyrus logu. Pro běžné hraní nechte **Vypnuto**. Použijte **Události** při hlášení chyby; **Každá kontrola** jen pokud stíháte timing problém, pak ho zase vypněte. Může ovlivnit výkon, zvlášť při každé kontrole.

  Logování funguje, jen když hra zapisuje Papyrus logy. V `Documents\My Games\Skyrim Special Edition\` upravte `Skyrim.ini` nebo `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Restartujte. Soubor logu: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Hledejte `fth_IJW`.

---

## Diagnostika

- **Editor ID načteny** - indikátor. Jména na stránce Scéna a nadřazený úkol, když svítí; čísla ID, když je zhasnutý. Form ID je pořád surové `0x…` v obou případech.

- **Hlídač** - zda běží kontrola na pozadí:
  - **Běží** - v pořádku
  - **Probouzí se** - normální hned po načtení
  - **Opožděno** - stále pracuje, ale kontroly jsou pomalejší než obvykle (vytížená hra)
  - **Vypnuto** - nastavili jste Kontrolovat každých na 0
  - **Uspáno** - Zapnuto je vypnuté v Nastavení

- **Poslední samooprava** - mod občas opraví vlastní účetnictví (často po načtení). Řádek tady je normální.

- **Verze**

---

## Řešení potíží

### Scény se zobrazují jako čísla ID, ne jména

po3 Tweaks nenačítá Editor ID. V `po3_Tweaks.ini` nastavte `Load EditorIDs = true` a restartujte Skyrim; kontrolka **Editor ID načteny** na stránce Diagnostika to potvrdí. Správci modů mohou tento soubor při nasazení nebo aktualizaci přepsat, takže upravte kopii *uvnitř* modu Tweaks (nebo malý override mod, který vyhraje), ne jen volný soubor v `Data`:

- **MO2:** složka modu Tweaks v levém panelu, nebo Overwrite / mod s vyšší prioritou.
- **Vortex:** staging složka Tweaks, nebo override mod. Po každé aktualizaci znovu zkontrolujte.

Form ID se zobrazí tak jako tak, takže nikdy nejste úplně potmě.

### Oznámení jsou ve špatném jazyce

Oznámení v rohu se řídí **Nastavení > Jazyk oznámení**, ne jazykem hry ani tím, který překladový soubor menu je nainstalovaný. Angličtina je výchozí a záložní.

Normální běh instalátoru, který nastaví výchozí jazyk menu, předvyplní i tento ovládací prvek, takže menu a oznámení ladí. Pokud jste soubor menu jen vyměnili ručně, nebo jste aktualizovali bez opětovného spuštění tohoto kroku instalátoru, nastavte jazyk oznámení jednou tak, aby odpovídal vašemu menu.

### Menu je ve špatném jazyce

Menu MCM se řídí nastavením jazyka hry, ne jazykem oznámení výše. Skyrim načte překladový soubor, který odpovídá jazyku hry, takže anglická hra ukáže anglické menu, i když jste nainstalovali jiný jazyk. Změnit to jde dvěma způsoby:

- **Instalátor:** zaškrtněte svůj jazyk v kroku 1, pak ho v kroku 2 zvolte jako výchozí jazyk menu. To přepíše anglický soubor menu (a ponechá anglický `.bak`) **a** předvyplní jazyk oznámení tak, aby odpovídal.
- **Ručně:** přejmenujte `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` na `fth_ItJustWorks_ENGLISH.txt`, čímž nahradíte anglický soubor. To **nezmění** jazyk oznámení - nastavte ho v Nastavení tak, aby odpovídal, jinak oznámení zůstanou anglicky.

### Menu nebo oznámení zobrazují zkomolené nebo nečitelné znaky

Text je správně - vaše hra jen nemá žádné písmo, které dokáže tyto znaky vykreslit, takže se zobrazí jako guláš. Výchozí písmo Skyrimu pokrývá latinku a západoevropská písmena, ale ne cyrilici, čínštinu, japonštinu ani některé středoevropské znaky. Pokud provozujete menu nebo oznámení v některém z nich, nainstalujte font mod, který je obsahuje; většina neanglických sestav už nějaký má. Pokud ten váš ne, prohledejte Nexus a najděte písmo pokrývající váš jazyk - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) je široký výchozí bod.

### Žádné upozornění se nikdy neobjeví

Zkontrolujte stav Hlídače na stránce Diagnostika, pak číselníky Hlídače:

- Stav **Uspáno** - mod je vypnutý. Zapněte Zapnuto (Nastavení).
- Stav **Vypnuto** - Kontrolovat každých je 0. Nastavte zpět na 10-240 s.
- Upozornit po je **0** - to vypíná upozornění. Nastavte počet minut, který chcete.

Upozornění používá čas stejným způsobem jako Upozornit po, takže čas ve scéně může občas ukazovat vysokou hodnotu bez upozornění - to je normální. Je to reálný čas a při načtení se vynuluje. I bez oznámení menu vždy ukazuje aktuální scénu a jak dlouho v ní jste.

### Zastavit scénu scénu nevyčistilo

Zastavení dosud ani jednou neselhalo - za víc než 10 let odseknávání savů, nejdřív s hrubými jednorázovými verzemi a teď s tímhle. Takže pokud to někdy nahlásí, že se scéna neukončila, buď jste našli chybu v modu, nebo něco opravdu nového. To je vzrušující. Překvapení je místo, kde se učíme. Úplný log je nejlepší šance to vypátrat. Zapněte Papyrus logování, nastavte Diagnostický log na **Každá kontrola** a zapněte každou možnost logu nebo ladění, kterou napříč svým load orderem najdete, aby se to, pokud se to stane znovu, zachytilo. Pak pošlete úplný `Papyrus.0.log` jako hlášení chyby. Mezitím se vraťte k načtení z doby před zaseknutím a hrajte dál.

### Podání hlášení chyby, nebo žádost o pomoc

U chyby nastavte Diagnostický log na **Události**, problém reprodukujte a pak ukončete hru. Se zapnutým Papyrus logováním (řádky `Skyrim.ini` jsou pod Nastavení) otevřete `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` a hledejte `fth_IJW`. Přiložte to, form ID scény a nadřazený úkol a co jste dělali, když se to zaseklo.

Kam to poslat:

- **Hlášení chyb:** [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) na stránce modu, nebo [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Dotazy a obecná pomoc:** [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) na stránce modu.

---

## Odinstalovat

**Odstranit natrvalo:**

1. Na stránce Nastavení vypněte Zapnuto.
2. Uložte, ukončete na plochu.
3. Odstraňte mod ve svém správci (nebo ručně).

Bezpečné odstranit uprostřed průchodu hrou. Skyrim může v save nechat malý neaktivní stub skriptu, jako jiné skriptované mody; hra ho ignoruje. Volitelné: cleaner save (např. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** ve FallrimTools) může stuby po odstranění vyčistit - cleanery používejte opatrně a jen na to, co opravdu chcete odstranit. Tento mod můžete nechat nainstalovaný, zatímco čistíte odpad z *jiných* modů.
