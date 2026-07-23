# Jak používat It Just Works™

## Co dělá

Skyrim používá *scény* pro rozhovory, cutscény a další skriptované momenty. Někdy scéna nikdy neskončí. To může tiše zablokovat pozdější scény - quest, který se nehne, bez chyby a bez pádu. Tento mod sleduje scénu, ve které jste, upozorní vás, pokud jste v jedné příliš dlouho, ukáže vám, která to je, a nechá vás ji zastavit, pokud se zasekla.

**Stručně:** nechte výchozí hodnoty zapnuté a hrajte dál. Když přijde upozornění, otevřete **Menu konfigurace modů > It Just Works**.

Potřebuje **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** a **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (s `Load EditorIDs = true`, pokud chcete jména místo čísel ID). Poznámky k instalaci jsou na [stránce modu](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Pět stránek: **Scéna**, **Hlídač**, **Nastavení**, **Diagnostika**, **Odinstalovat**.

---

## Menu v jiném jazyce

Mod dodává překlady menu - vyberte je v instalátoru. Skyrim načte soubor, který odpovídá **nastavení jazyka** hry. Anglická hra + jiný nainstalovaný jazyk dál čte anglický soubor menu, dokud to nepřepíšete.

**Instalátor:** zaškrtněte jazyk v kroku 1, pak ho nastavte jako výchozí jazyk menu v kroku 2 (zapíše přes anglický soubor; ponechá anglický `.bak`).

**Ručně:** přejmenujte `Interface\Translations\fth_ItJustWorks_CZECH.txt` na `fth_ItJustWorks_ENGLISH.txt` (nahraďte anglický soubor).

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

  Jména zapnout: v `po3_Tweaks.ini` nastavte `Load EditorIDs = true`, restartujte Skyrim. Mod to také jednou řekne, když poprvé zjistí, že jména jsou vypnutá. Správci modů mohou tento soubor při nasazení nebo aktualizaci přepsat — upravte kopii *uvnitř* modu Tweaks (nebo malý override mod, který vyhraje), ne jen volný soubor v `Data`. **MO2:** složka modu v levém panelu, nebo Overwrite / mod s vyšší prioritou. **Vortex:** staging složka Tweaks, nebo override mod; po aktualizacích znovu zkontrolujte.

- **Hlídač** - zda běží kontrola na pozadí:
  - **Běží** - v pořádku
  - **Probouzí se** - normální hned po načtení
  - **Opožděno** - stále pracuje, ale kontroly jdou pomaleji než obvykle (vytížená hra)
  - **Vypnuto (kontroly zakázány)** - nastavili jste **Kontrolovat každých** na 0
  - **Uspáno (vypnuto)** - **Zapnuto** je vypnuté na stránce **Nastavení**

- **Poslední samooprava** - mod občas opraví vlastní účetnictví (často po načtení). Řádek tady je normální.

- **Verze**

---

## Odinstalovat

**Odstranit natrvalo:**

1. Na stránce **Nastavení** vypněte **Zapnuto**.
2. Uložte, ukončete na plochu.
3. Odstraňte mod ve správci (nebo ručně).

Bezpečné odstranit uprostřed průchodu. Skyrim může v save nechat malý inertní stub skriptu, jako jiné skriptované mody; hra ho ignoruje. Volitelně: cleaner save (např. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** ve FallrimTools) může stuby po odstranění vyčistit - cleanery používejte opatrně a jen na to, co jste opravdu chtěli odstranit. Tento mod můžete nechat nainstalovaný, zatímco čistíte odpad z *jiných* modů.
