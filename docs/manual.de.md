# It Just Works™ verwenden

## Was er macht

Skyrim nutzt *Szenen* für Gespräche, Zwischensequenzen und andere skriptgesteuerte Momente. Manchmal endet eine Szene nie. Das kann still spätere Szenen blockieren - eine Quest, die nicht weitergeht, kein Fehler, kein Absturz. Dieser Mod beobachtet die Szene, in der du gerade steckst, warnt dich, wenn du schon eine Weile darin bist, zeigt dir, welche es ist, und lässt dich sie stoppen, wenn sie klemmt.

**Kurzfassung:** Lass die Standardeinstellungen an, spiel weiter. Wenn du eine Warnung bekommst, öffne **Mod-Konfigurationsmenü > It Just Works**.

Er bearbeitet keine Datensätze anderer Mods und braucht keine Patches, daher spielt die Platzierung in der Ladereihenfolge gegenüber deinem Content-Stack keine Rolle. Er ändert eine Szene nur, wenn du ihm sagst, dass sie gestoppt werden soll.

Benötigt **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** und **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (mit `Load EditorIDs = true`, wenn du Namen statt ID-Nummern willst). Installationshinweise stehen auf der [Mod-Seite](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Fünf Seiten: **Szene**, **Wächter**, **Einstellungen**, **Diagnose**, **Deinstallation**.

---

## Szene

### Worin du steckst

Anzeige der aktuellen Szene, oder **Keine**. Das Menü aktualisiert sich beim Öffnen.

- **Zeit in der Szene** - ungefähr, wie lange du in dieser Sitzung schon in dieser Szene bist (Echtzeit).
- **Szene** - Name, wenn verfügbar; sonst eine ID-Nummer.
- **Form ID** - die rohe ID, immer sichtbar. Nützlich für die Konsole oder einen Fehlerbericht.
- **Zugehörige Quest** - zu welcher Quest die Szene gehört.

### Szene stoppen

Wenn du glaubst, dass die Szene feststeckt, beendet das sie.

1. Drücke **Szene stoppen** einmal - eine Zeile bestätigt, dass sie scharf ist.
2. Erneut drücken zum Abbrechen, oder das Menü schließen zum Stoppen.

Stoppe nur eine Szene, die du für feststeckend hältst. Eine normale zu stoppen kann etwas kaputt machen. Eine feststeckende zu stoppen kann (selten) einen kurzen Schwall verzögerter Ereignisse auslösen, während das Spiel aufholt.

**Aktualisieren** liest die aktuelle Szene neu, ohne das Menü zu schließen. Im unveränderten Skyrim ist Aktualisieren wahrscheinlich nicht nützlich, da das Spiel in Menüs pausiert. Wenn du einen Unpause-Mod wie [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859) verwendest, kannst du damit aktualisieren, ohne das Menü neu zu öffnen.

### Letzte Szenen

Die letzten zehn Szenen, neueste zuerst, mit grober Dauer.

---

## Wächter

Wacht, damit du es nicht musst.

- **Warnen nach** - wie lange eine Szene laufen darf, bevor du eine Warnung bekommst. Standard **6** Minuten. **0** = nie.  
  Nichts im Spiel markiert eine Szene als feststeckend, und nichts im Spiel sagt uns, wie lange eine Szene laufen soll. Also setzen wir eine Schwelle und warnen dich. Wir kombinieren Spielzeit und Echtzeit auf eine Art, von der wir hoffen, dass sie ungefähr „tatsächlich mit Spielen verbrachte Echtzeit" abbildet, damit sich die Einstellung intuitiv anfühlt.
- **Prüfen alle** - Sekunden zwischen Prüfungen. Standard **30**. **0** = schaltet den Wächter aus.
- **Wiederholte Warnungen** - standardmäßig aus, sodass du eine Warnung pro Szene bekommst. Einschalten, um weiter zu warnen, solange du über der Schwelle bist.
- **Wiederholen alle** - Minuten zwischen Warnungen, nur verwendet, wenn Wiederholte Warnungen an ist. Standard **5**.

Eine Warnung besteht aus zwei Zeilen in der Ecke, zum Beispiel:

> Szene blockiert andere ~6m  
> See? It Just Works!

Standardmäßig eine Warnung pro Szene, bis du sie verlässt oder die Szene wechselt. Verpasst? Öffne das Menü - die Anzeige zeigt weiterhin, worin du steckst und wie lange. Der Mod stoppt die Szene nicht von selbst; benutze dafür Szene stoppen auf der Seite Szene.

Der Wächter verhält sich gleich, egal ob deine Menüs die Welt pausieren (unverändertes Spiel) oder weiterlaufen lassen (Unpause-Setups wie [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) - eine Warnung bedeutet weiterhin nur, dass die Szene schon eine Weile läuft.

---

## Einstellungen

- **Aktiviert** - standardmäßig an. Ausschalten legt den Mod zur Seite, ohne ihn zu deinstallieren.
- **Leichtigkeit** - standardmäßig an. Benachrichtigungen behalten einen lockeren Ton; ausschalten für schlichten Text. Nur der Text ändert sich, nie die Funktionsweise des Mods.
- **Sprache der Benachrichtigungen** - Sprache für die eigenen Benachrichtigungen des Mods in der Ecke. Der Installer kann sie vorbelegen, wenn du eine Standard-Menüsprache wählst; ändere sie jederzeit auf dieser Seite. Standardmäßig Englisch und als Rückfallebene; unabhängig von der Spracheinstellung des Spiels.
- **Aktuelle Szene benennen** - belege eine Taste; drücken zeigt den aktuellen Szenennamen, ohne das Menü zu öffnen.
- **Belegung löschen** - entfernt die Belegung.
- **Diagnoseprotokoll** - wie viel ins Papyrus-Log geht. Für normales Spielen auf **Aus** lassen. Benutze **Ereignisse** beim Melden eines Fehlers; **Jede Prüfung** nur, wenn du einem Timing-Problem nachgehst, danach wieder ausschalten. Kann die Leistung beeinträchtigen, besonders bei Jede Prüfung.

  Protokollierung funktioniert nur, wenn das Spiel Papyrus-Logs schreibt. Bearbeite in `Documents\My Games\Skyrim Special Edition\` die Datei `Skyrim.ini` oder `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Neu starten. Logdatei: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Suche nach `fth_IJW`.

---

## Diagnose

- **Editor IDs geladen** - eine Anzeige. Namen auf der Seite Szene und bei der zugehörigen Quest, wenn sie leuchtet; ID-Nummern, wenn sie dunkel ist. Form ID bleibt so oder so die rohe `0x…`.

- **Wächter** - ob die Hintergrundprüfung läuft:
  - **Läuft** - in Ordnung
  - **Wacht auf** - normal direkt nach einem Neuladen
  - **Verspätet** - arbeitet noch, aber Prüfungen sind langsamer als gewöhnlich (viel los im Spiel)
  - **Aus (Prüfungen deaktiviert)** - du hast Prüfen alle auf 0 gesetzt
  - **Ruht (abgeschaltet)** - Aktiviert ist unter Einstellungen aus

- **Letzte Selbstreparatur** - der Mod korrigiert manchmal seine eigene Buchhaltung (oft nach einem Neuladen). Eine Zeile hier ist normal.

- **Version**

---

## Fehlerbehebung

### Szenen erscheinen als ID-Nummern, nicht als Namen

po3 Tweaks lädt keine Editor IDs. Setze in `po3_Tweaks.ini` `Load EditorIDs = true` und starte Skyrim neu; die Anzeige **Editor IDs geladen** auf der Seite Diagnose bestätigt es. Mod-Manager können diese Datei beim Bereitstellen oder Aktualisieren überschreiben, bearbeite also die Kopie *innerhalb* des Tweaks-Mods (oder einen kleinen Override-Mod, der gewinnt), nicht nur eine lose Datei in `Data`:

- **MO2:** der Tweaks-Mod-Ordner im linken Bereich, oder Overwrite / ein höher priorisierter Mod.
- **Vortex:** der Tweaks-Staging-Ordner, oder ein Override-Mod. Nach jedem Update erneut prüfen.

Form ID wird so oder so angezeigt, du tappst also nie völlig im Dunkeln.

### Die Benachrichtigungen sind in der falschen Sprache

Die Benachrichtigungen in der Ecke folgen **Einstellungen > Sprache der Benachrichtigungen**, nicht der Sprache des Spiels und nicht der installierten Menü-Übersetzungsdatei. Englisch ist der Standard und die Rückfallebene.

Ein normaler Installer-Lauf, der die Standard-Menüsprache setzt, belegt auch diese Einstellung vor, sodass Menü und Benachrichtigungen zusammenpassen. Wenn du die Menüdatei nur von Hand getauscht oder ohne erneutes Ausführen dieses Installer-Schritts aktualisiert hast, stelle Sprache der Benachrichtigungen einmal passend zu deinem Menü ein.

### Das Menü ist in der falschen Sprache

Das MCM-Menü folgt der Spracheinstellung des Spiels, nicht der oben genannten Sprache der Benachrichtigungen. Skyrim lädt die Übersetzungsdatei, die zur Spielsprache passt, daher zeigt ein englisches Spiel das englische Menü, selbst wenn du eine andere Sprache installiert hast. Zwei Wege, das zu ändern:

- **Installer:** Kreuze deine Sprache in Schritt 1 an, wähle sie dann in Schritt 2 als Standard-Menüsprache. Das überschreibt die englische Menüdatei (und behält ein englisches `.bak`) **und** belegt die Sprache der Benachrichtigungen passend vor.
- **Von Hand:** Benenne `Interface\Translations\fth_ItJustWorks_<LANGUAGE>.txt` in `fth_ItJustWorks_ENGLISH.txt` um und ersetze damit die englische Datei. Das ändert die Sprache der Benachrichtigungen **nicht** - stelle sie unter Einstellungen passend ein, sonst bleiben die Benachrichtigungen englisch.

### Das Menü oder die Benachrichtigungen zeigen wirre oder unlesbare Zeichen

Der Text ist richtig - dein Spiel hat nur keine Schriftart, die diese Zeichen darstellen kann, also erscheint Kauderwelsch. Skyrims Standardschrift deckt lateinische und westeuropäische Buchstaben ab, aber kein Kyrillisch, Chinesisch, Japanisch oder manche mitteleuropäischen Zeichen. Wenn du das Menü oder die Benachrichtigungen in einer davon nutzt, installiere einen Font-Mod, der sie enthält; die meisten nicht-englischen Setups haben bereits einen. Falls deiner nicht, suche auf Nexus nach einer Schriftart für deine Sprache - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) ist ein guter Ausgangspunkt.

### Es erscheint nie eine Warnung

Prüfe den Wächter-Status auf der Seite Diagnose, dann die Wächter-Regler:

- Status **Ruht (abgeschaltet)** - der Mod ist aus. Schalte Aktiviert ein (Einstellungen).
- Status **Aus (Prüfungen deaktiviert)** - Prüfen alle steht auf 0. Setze es zurück auf 10-240 s.
- Warnen nach ist **0** - das schaltet die Warnung ab. Stelle die gewünschten Minuten ein.

Die Warnung nutzt Zeit auf dieselbe Art wie Warnen nach, daher kann Zeit in der Szene gelegentlich hoch anzeigen, ohne dass eine Warnung kommt - das ist normal. Es ist Echtzeit und setzt sich bei einem Neuladen zurück. Auch ohne Benachrichtigung zeigt das Menü immer die aktuelle Szene und wie lange du schon darin bist.

### Szene stoppen hat die Szene nicht aufgelöst

Ein Stopp ist in über 10 Jahren des Losmachens feststeckender Saves noch nie fehlgeschlagen - erst mit groben Einzelversionen, jetzt mit diesem Mod. Wenn er also je meldet, dass die Szene nicht endete, hast du entweder einen Bug im Mod gefunden, oder etwas wirklich Neues. Das ist spannend. Überraschung ist da, wo Lernen passiert. Ein vollständiges Log ist die beste Chance, es aufzuspüren. Schalte Papyrus-Logging ein, stelle Diagnoseprotokoll auf **Jede Prüfung**, und aktiviere jede Log- oder Debug-Option, die du in deiner gesamten Ladereihenfolge findest, damit es festgehalten wird, falls es wieder passiert. Schicke dann das vollständige `Papyrus.0.log` als Fehlerbericht. Lade in der Zwischenzeit von vor dem Feststecken neu, um weiterzuspielen.

### Einen Fehler melden oder um Hilfe bitten

Stelle für einen Fehler Diagnoseprotokoll auf **Ereignisse**, reproduziere das Problem und beende dann. Bei eingeschaltetem Papyrus-Logging (die `Skyrim.ini`-Zeilen stehen unter Einstellungen) öffne `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` und suche nach `fth_IJW`. Füge das bei, dazu die Form ID und Zugehörige Quest der Szene, und was du getan hast, als sie feststeckte.

Wohin damit:

- **Fehlerberichte:** der [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) auf der Mod-Seite, oder [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Fragen und allgemeine Hilfe:** der [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) auf der Mod-Seite.

---

## Deinstallation

**Endgültig entfernen:**

1. Schalte auf der Seite Einstellungen Aktiviert aus.
2. Speichern, zum Desktop beenden.
3. Entferne den Mod in deinem Manager (oder von Hand).

Sicher mitten im Durchgang entfernbar. Skyrim kann einen kleinen inerten Script-Stub im Save zurücklassen, wie andere Script-Mods auch; das Spiel ignoriert ihn. Optional: Ein Save-Cleaner (z. B. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) kann Stubs nach der Entfernung bereinigen - benutze Cleaner vorsichtig, nur bei dem, was du wirklich entfernen willst. Du kannst diesen Mod installiert lassen, während du Müll von *anderen* Mods bereinigst.
