# It Just Works™ verwenden

## Was er macht

Skyrim nutzt *Szenen* für Gespräche, Zwischensequenzen und andere skriptgesteuerte Momente. Manchmal endet eine Szene nie. Das kann still spätere Szenen blockieren - eine Quest, die nicht weitergeht, kein Fehler, kein Absturz. Dieser Mod beobachtet die Szene, in der du bist, warnt dich, wenn du zu lange in einer festhängst, zeigt dir, welche es ist, und lässt dich sie stoppen, wenn sie klemmt.

**Kurzfassung:** lass die Standardwerte an, spiel weiter. Wenn eine Warnung kommt, öffne **Mod-Konfigurationsmenü > It Just Works**.

Benötigt **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** und **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (mit `Load EditorIDs = true`, wenn du Namen statt ID-Nummern willst). Installationshinweise stehen auf der [Mod-Seite](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Drei Seiten im Menü: **Szene**, **Diagnose**, **Deinstallation**.

---

## Das Menü in einer anderen Sprache anzeigen

Der Mod liefert Menü-Übersetzungen - wähle sie im Installer. Skyrim lädt die Datei, die zur **Spracheinstellung** des Spiels passt. Englisches Spiel + andere installierte Sprache liest weiter die englische Menüdatei, bis du das überschreibst.

**Installer:** Sprache in Schritt 1 ankreuzen, dann in Schritt 2 als Standard-Menüsprache setzen (schreibt über die englische Datei; behält eine englische `.bak`).

**Von Hand:** `Interface\Translations\fth_ItJustWorks_GERMAN.txt` in `fth_ItJustWorks_ENGLISH.txt` umbenennen (englische Datei ersetzen).

---

## Szene

### Worin du steckst

Live-Anzeige der aktuellen Szene, oder **None**. Menü öffnen für eine frische Messung.

- **Zeit in der Szene** - die Zeile, die hier meist zählt: ungefähr wie lange du in dieser Sitzung drin bist (`~` = ungefähr). Das ist das Signal für feststecken oder nicht. **Ein Neuladen setzt diesen Timer zurück.** Durchgehendes Spielen nach dem Neuladen kann weiterhin warnen; kurze Neulade-Schleifen ohne langes Im-Spiel-Bleiben nicht.
- **Szene** - Name, wenn Namen verfügbar sind; sonst eine ID-Nummer (siehe Editor IDs unter Diagnose).
- **Form ID** - die rohe ID, immer sichtbar. Nützlich für Konsole oder Fehlerbericht; zum Stoppen brauchst du sie nicht - dafür ist der Knopf unten.
- **Zugehörige Quest** - zu welcher Quest die Szene gehört, wenn du den weiteren Kontext willst.

### Szene stoppen

Wenn du glaubst, die Szene steckt fest, beendet das sie.

1. Drücke **Szene stoppen** einmal - eine Zeile bestätigt, dass sie scharf ist.
2. Erneut drücken zum Abbrechen, oder **Menü schließen** zum Stoppen. Der Stopp läuft, wenn das Menü schließt.

Stoppe nur eine Szene, die du für feststeckend hältst. Eine normale zu stoppen kann etwas kaputt machen. Eine feststeckende zu stoppen kann einen kurzen Schwall verzögerter Ereignisse auslösen - erwartet, kein neues Problem.

**Aktualisieren** liest die aktuelle Szene neu, ohne das Menü zu schließen. Öffnen misst schon frisch; nutze das, wenn das Menü länger offen war und du ein Update willst - besonders bei Mods wie [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), die das Spiel unter Menüs weiterlaufen lassen.

### Letzte Szenen

Die letzten zehn Szenen, neueste zuerst, mit grober Dauer. Dieselbe Art ungefährer Zeit wie oben (Neuladen führt keine Stoppuhr über Sitzungen).

### Wächter

Auf derselben Seite. Wacht, damit du es nicht musst.

- **Warnen nach** - Minuten in einer Szene vor einer Warnung. Standard **3**. **0** = nie warnen.
- **Prüfen alle** - Sekunden zwischen Prüfungen. Standard **30**. **0** = Wächter aus.

Warnung sind zwei Zeilen in der Ecke, zum Beispiel:

> scene blocking others ~3m  
> See? It Just Works!

Einmal pro Szene, bis du sie verlässt oder die Szene wechselt. Toast verpasst? Menü öffnen - die Anzeige zeigt weiter, worin du bist und wie lange. Der Mod stoppt die Szene nicht von allein; das ist **Szene stoppen**.

### Hotkey

- **Aktuelle Szene benennen** - Taste belegen; drücken zeigt den aktuellen Szenennamen ohne Menü.
- **Belegung löschen** - entfernt die Belegung. ESC löscht sie hier nicht (ESC ist Pause in diesem Menü).

---

## Diagnose

- **Editor IDs geladen** - Statusanzeige, kein Schalter (Klick springt zurück).
  - **Leuchtet** - Namen sind an.
  - **Dunkel** - du siehst ID-Nummern; der Mod funktioniert trotzdem.

  Namen an: in `po3_Tweaks.ini` `Load EditorIDs = true` setzen, Skyrim neu starten. Der Mod sagt das auch einmal, wenn er merkt, dass Namen aus sind.

- **Wächter** - ob die Hintergrundprüfung läuft:
  - **Läuft** - in Ordnung
  - **Wacht auf** - normal kurz nach einem Neuladen
  - **Verspätet** - noch aktiv, aber Prüfungen kommen langsamer (viel Script-Last)
  - **Aus (Prüfungen deaktiviert)** - du hast Prüfen alle auf 0 gesetzt
  - **Ruht (abgeschaltet)** - Aktiviert ist unter Deinstallation aus

- **Letzte Selbstreparatur** - der Mod korrigiert manchmal seine eigene Buchhaltung (oft nach einem Neuladen). Eine Zeile hier ist normal. Kein Fehler, nichts zum Löschen.

- **Diagnoseprotokoll** - wie viel ins Papyrus-Log geht. Für normales Spielen **Aus**. **Ereignisse** beim Melden eines Fehlers; **Jede Prüfung** nur bei Timing-Problemen, dann zurück.

  Logging funktioniert nur, wenn das Spiel Papyrus-Logs schreibt. Unter `Documents\My Games\Skyrim Special Edition\` in `Skyrim.ini` oder `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Neu starten. Logdatei: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Suche nach `fth_IJW`.

- **Version** - Build-Nummer, für Hilfethreads und Updates.

---

## Ausschalten oder entfernen

**Zur Seite legen:** Seite Deinstallation → **Aktiviert** aus. Wächter und Hotkey stoppen; später wieder an, und er macht weiter. Dein Spielstand ist in Ordnung.

**Endgültig entfernen:**

1. **Aktiviert** aus.
2. Speichern, zum Desktop beenden.
3. Mod im Manager entfernen (oder von Hand).

Sicher mitten im Durchlauf entfernbar. Skyrim kann einen kleinen inerten Script-Stub im Save lassen, wie andere Script-Mods; das Spiel ignoriert ihn. Optional: Save-Cleaner (z. B. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) nach dem Entfernen - vorsichtig, nur was du meintest. Du kannst diesen Mod installiert lassen, während du Müll von *anderen* Mods säuberst.
