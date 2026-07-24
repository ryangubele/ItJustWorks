# It Just Works™ verwenden

## Was er macht

Skyrim nutzt *Szenen* für Gespräche, Zwischensequenzen und andere skriptgesteuerte Momente. Manchmal endet eine Szene nie. Das kann still spätere Szenen blockieren - eine Quest, die nicht weitergeht, kein Fehler, kein Absturz. Dieser Mod beobachtet die Szene, in der du bist, warnt dich, wenn du zu lange in einer festhängst, zeigt dir, welche es ist, und lässt dich sie stoppen, wenn sie klemmt.

**Kurzfassung:** lass die Standardwerte an, spiel weiter. Wenn eine Warnung kommt, öffne **Mod-Konfigurationsmenü > It Just Works**.

Benötigt **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** und **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (mit `Load EditorIDs = true`, wenn du Namen statt ID-Nummern willst). Installationshinweise stehen auf der [Mod-Seite](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Fünf Seiten: **Szene**, **Wächter**, **Einstellungen**, **Diagnose**, **Deinstallation**.

---

## Szene

### Worin du steckst

Live-Anzeige der aktuellen Szene, oder **None**. Menü öffnen für eine frische Messung.

- **Zeit in der Szene** - ungefähr wie lange du schon in dieser Szene bist; ein Neuladen des Spiels setzt sie zurück. Das ist das Signal für feststecken oder nicht.
- **Szene** - Name, wenn Namen verfügbar sind; sonst eine ID-Nummer.
- **Form ID** - die rohe ID, immer sichtbar. Nützlich für Konsole oder Fehlerbericht.
- **Zugehörige Quest** - zu welcher Quest die Szene gehört.

### Szene stoppen

Wenn du glaubst, die Szene steckt fest, beendet das sie.

1. Drücke **Szene stoppen** einmal - eine Zeile bestätigt, dass sie scharf ist.
2. Erneut drücken zum Abbrechen, oder **Menü schließen** zum Stoppen.

Stoppe nur eine Szene, die du für feststeckend hältst. Eine normale zu stoppen kann etwas kaputt machen. Eine feststeckende zu stoppen kann (selten) einen kurzen Schwall verzögerter Ereignisse auslösen, während das Spiel aufholt.

**Aktualisieren** liest die aktuelle Szene neu, ohne das Menü zu schließen. Im unveränderten Skyrim ist das Spiel in Menüs normalerweise pausiert, daher ist **Aktualisieren** vermutlich nicht nützlich. Wenn du einen Mod wie [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859) verwendest, der das Spiel nicht pausiert, kannst du damit das Menü aktualisieren, ohne es neu zu öffnen.

### Letzte Szenen

Die letzten zehn Szenen, neueste zuerst, mit grober Dauer. Dieselbe Art ungefährer Zeit wie oben.

---

## Wächter

Wacht, damit du es nicht musst.

- **Warnen nach** - Minuten in einer Szene vor einer Warnung. Standard **3**. **0** = nie warnen.
- **Prüfen alle** - Sekunden zwischen Prüfungen. Standard **30**. **0** = Wächter aus.

Warnung sind zwei Zeilen in der Ecke, zum Beispiel:

> scene blocking others ~3m  
> See? It Just Works!

Einmal pro Szene, bis du sie verlässt oder die Szene wechselt. Toast verpasst? Menü öffnen - die Anzeige zeigt weiter, worin du bist und wie lange. Der Mod stoppt die Szene nicht von allein; das ist **Szene stoppen**.

---

## Einstellungen

- **Aktiviert** - standardmäßig an. Ausschalten legt den Mod zur Seite, ohne ihn zu deinstallieren.
- **Leichtigkeit** - standardmäßig an. Die Benachrichtigungen behalten einen lockeren Ton; ausschalten für schlichten Text. Nur der Text ändert sich, nie die Funktion des Mods.
- **Sprache der Benachrichtigungen** - die Sprache der eigenen Pop-up-Benachrichtigungen des Mods (die Toasts in der Ecke). Stelle sie auf deine Menüsprache ein. Standardmäßig Englisch; unabhängig von der Spracheinstellung des Spiels.
- **Aktuelle Szene benennen** - Taste belegen; drücken zeigt den aktuellen Szenennamen ohne Menü.
- **Belegung löschen** - entfernt die Belegung.
- **Diagnoseprotokoll** - wie viel ins Papyrus-Log geht. Für normales Spielen **Aus**. **Ereignisse** beim Melden eines Fehlers; **Jede Prüfung** nur bei Timing-Problemen, dann wieder ausschalten. Kann die Leistung beeinträchtigen, besonders bei **Jede Prüfung**.

  Logging funktioniert nur, wenn das Spiel Papyrus-Logs schreibt. Unter `Documents\My Games\Skyrim Special Edition\` in `Skyrim.ini` oder `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Neu starten. Logdatei: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Suche nach `fth_IJW`.

---

## Diagnose

- **Editor IDs geladen** - eine Anzeige. Namen auf **Szene** und zugehöriger Quest, wenn sie leuchtet; ID-Nummern, wenn sie dunkel ist. **Form ID** ist so oder so weiterhin die rohe `0x…`.

- **Wächter** - ob die Hintergrundprüfung läuft:
  - **Läuft** - in Ordnung
  - **Wacht auf** - normal kurz nach einem Neuladen
  - **Verspätet** - noch aktiv, aber Prüfungen kommen langsamer (viel Script-Last)
  - **Aus (Prüfungen deaktiviert)** - du hast **Prüfen alle** auf 0 gesetzt
  - **Ruht (abgeschaltet)** - **Aktiviert** ist unter **Einstellungen** aus

- **Letzte Selbstreparatur** - der Mod korrigiert manchmal seine eigene Buchhaltung (oft nach einem Neuladen). Eine Zeile hier ist normal.

- **Version**

---

## Fehlerbehebung

### Szenen erscheinen als ID-Nummern, nicht als Namen

po3 Tweaks lädt keine Editor IDs. Setze in `po3_Tweaks.ini` `Load EditorIDs = true` und starte Skyrim neu; die Anzeige *Editor IDs geladen* auf der Seite **Diagnose** bestätigt es. Mod-Manager können diese Datei beim Deploy oder Update überschreiben, bearbeite also die Kopie *innerhalb* des Tweaks-Mods (oder einen kleinen Override-Mod, der gewinnt), nicht nur eine lose Datei in `Data`:

- **MO2:** der Tweaks-Mod-Ordner im linken Bereich, oder Overwrite / ein höher priorisierter Mod.
- **Vortex:** der Tweaks-Staging-Ordner, oder ein Override-Mod. Nach jedem Update erneut prüfen.

Die **Form ID** wird so oder so angezeigt, du tappst also nie völlig im Dunkeln.

### Die Benachrichtigungen sind in der falschen Sprache

Der Mod hat zwei unabhängige Sprachen-Einstellungen; diese ist für seine eigenen Pop-up-Benachrichtigungen. Stelle **Einstellungen > Sprache der Benachrichtigungen** auf deine Sprache - sie steuert die Toasts in der Ecke (die Warnung zur feststeckenden Szene, den Namen-Hinweis, die Stopp-Ergebnisse). Sie ist unabhängig von der Sprache des Spiels und von der Menüsprache unten. Englisch ist der Standard und die Rückfallebene, sodass eine nicht übersetzte Zeile auf Englisch erscheint, statt zu brechen.

### Das Menü ist in der falschen Sprache

Das MCM-Menü folgt der **Spracheinstellung** des Spiels, nicht der Benachrichtigungssprache oben. Skyrim lädt die Übersetzungsdatei, die zur Spielsprache passt, daher zeigt ein englisches Spiel das englische Menü, selbst wenn du eine andere Sprache installiert hast. Zwei Wege, das zu ändern:

- **Installer:** Sprache in Schritt 1 ankreuzen, dann in Schritt 2 als Standard-Menüsprache wählen (schreibt über die englische Datei und behält eine englische `.bak`).
- **Von Hand:** `Interface\Translations\fth_ItJustWorks_GERMAN.txt` in `fth_ItJustWorks_ENGLISH.txt` umbenennen und die englische Datei ersetzen.

### Das Menü oder die Benachrichtigungen zeigen wirre oder unlesbare Zeichen

Der Text stimmt - dein Spiel hat nur keine Schrift, die diese Zeichen darstellen kann, also erscheint Kauderwelsch. Skyrims Standardschrift deckt lateinische und westeuropäische Buchstaben ab, aber kein Kyrillisch, Chinesisch, Japanisch oder manche mitteleuropäischen Zeichen. Wenn du das Menü oder die Benachrichtigungen in einer davon nutzt, installiere einen **Schrift-Mod**, der sie enthält; die meisten nicht-englischen Setups haben schon einen. Falls deiner nicht, suche auf Nexus nach einer Schrift für deine Sprache - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) ist ein breiter Ausgangspunkt.

### Es erscheint nie eine Warnung

Prüfe den **Wächter**-Status auf der Seite **Diagnose**, dann die **Wächter**-Regler:

- Status **Ruht (abgeschaltet)** - der Mod ist aus. Schalte **Aktiviert** ein (Einstellungen).
- Status **Aus (Prüfungen deaktiviert)** - **Prüfen alle** steht auf 0. Setze es zurück auf 10-240 s.
- **Warnen nach** ist **0** - das schaltet die Warnung ab. Stelle die gewünschten Minuten ein.

Die **Zeit in der Szene** setzt sich bei einem Neuladen zurück, daher warnt eine Szene erst, wenn du in dieser Sitzung ununterbrochen über der Warnzeit in ihr warst. Auch ohne Toast zeigt das Menü immer die aktuelle Szene und wie lange du schon darin bist.

### Szene stoppen hat die Szene nicht aufgelöst

Ein Stopp hat noch nie versagt - nicht in 14 Jahren des Losmachens festhängender Saves, erst mit groben Einzelversionen und jetzt mit diesem. Wenn er also je meldet, dass die Szene nicht endete, hast du etwas wirklich Neues gefunden - das ist spannend, nicht beunruhigend. Überraschung ist da, wo Lernen passiert. Es gibt noch keine bekannte Ursache, und nichts ist versprochen, aber ein vollständiges Log ist die beste Chance, eine aufzuspüren. Schalte das Papyrus-Logging ein, stelle **Einstellungen > Diagnoseprotokoll** auf **Jede Prüfung**, und aktiviere jede Log- oder Debug-Option, die du in deiner gesamten Ladereihenfolge findest - damit es, falls es wieder passiert, festgehalten wird. Schicke dann das vollständige `Papyrus.0.log` als Fehlerbericht (Kanäle unten). Lade in der Zwischenzeit von vor dem Feststecken neu, um weiterzuspielen.

### Einen Fehler melden oder um Hilfe bitten

Für einen Fehler stelle **Einstellungen > Diagnoseprotokoll** auf **Ereignisse**, reproduziere das Problem und beende dann. Mit eingeschaltetem Papyrus-Logging (die `Skyrim.ini`-Zeilen stehen unter **Einstellungen**) öffne `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` und suche nach `fth_IJW`. Füge das bei, dazu die **Form ID** und **Zugehörige Quest** der Szene, und was du tatest, als sie feststeckte.

Wohin damit:

- **Fehlerberichte:** [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) auf der Mod-Seite, oder [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Fragen und allgemeine Hilfe:** [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) auf der Mod-Seite.

---

## Deinstallation

**Endgültig entfernen:**

1. Auf der Seite **Einstellungen** **Aktiviert** ausschalten.
2. Speichern, zum Desktop beenden.
3. Mod im Manager entfernen (oder von Hand).

Sicher mitten im Durchlauf entfernbar. Skyrim kann einen kleinen inerten Script-Stub im Save lassen, wie andere Script-Mods; das Spiel ignoriert ihn. Optional: Save-Cleaner (z. B. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) nach dem Entfernen - vorsichtig, nur was du meintest. Du kannst diesen Mod installiert lassen, während du Müll von *anderen* Mods säuberst.
