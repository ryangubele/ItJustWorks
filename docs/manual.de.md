# It Just Works™ verwenden

## Was er macht, und warum

Skyrim läuft auf *Szenen* - skriptgesteuerten Momenten wie Gesprächen und Zwischensequenzen, die eigentlich von selbst enden sollen. Manchmal tut eine das nicht, und eine festhängende Szene kann still die blockieren, die nach ihr kommen, und dabei leise eine Quest oder sogar einen ganzen Spielstand zerstören, ohne dass ein Fehler dich warnt. Dieser Mod beobachtet die Szene, in der du dich befindest, und warnt dich, wenn du zu lange in einer festhängst, zeigt dir in einem Menü, worin du steckst, und lässt dich eine Szene stoppen, die klemmt. Das ist die ganze Idee: den festhängenden Schalter erwischen, bevor er dich den Spielstand kostet.

Alles, was der Mod tut, steuerst du über eine einzige Seite: **Mod-Konfigurationsmenü > It Just Works**. Hier ist, was jeder Teil davon macht.

Die Kurzfassung, wenn du ihn gerade installiert hast: lass die Standardwerte in Ruhe, spiel weiter, und lass den Wächter dir auf die Schulter tippen, falls du je zu lange in einer Szene festhängst. Alles Weitere unten ist für die Momente, in denen du genauer hinsehen willst.

## Das Menü auf Deutsch anzeigen

Der Mod liefert Menü-Übersetzungen für mehrere Sprachen - wähle sie im Installer aus. Skyrim lädt die Übersetzung, die zur **Spracheinstellung** deines Spiels passt. Läuft dein Spiel also auf Englisch, willst aber das Menü in einer anderen Sprache, liest es weiterhin die englische Datei und das Menü bleibt englisch, obwohl die Übersetzung installiert ist. Zwei Lösungen: Hake im Installer im ersten Schritt diese Sprache an und wähle sie im zweiten als deine Standard-Menüsprache (er schreibt die Übersetzung für dich über die englische Datei und behält eine englische `.bak`, die du zurückbenennen kannst); oder benenne von Hand deine Sprachdatei in `Interface\Translations\` - `fth_ItJustWorks_GERMAN.txt` - in `fth_ItJustWorks_ENGLISH.txt` um und ersetze damit die englische.

## Aktuelle Szene

Oben auf der Seite steht eine Live-Anzeige der Szene, in der du dich gerade befindest, oder "None", wenn du in keiner bist. Beim Öffnen der Seite wird frisch gemessen, sie ist also nie veraltet.

- **Szene** - die Szene, in der du gerade bist, als Name (ihre Editor ID), wenn Namen verfügbar sind, sonst als rohe ID-Nummer (siehe die Anzeige unten).
- **Form ID** - die rohe ID-Nummer der Szene, immer sichtbar, falls du sie für die Konsole oder einen Fehlerbericht brauchst.
- **Zugehörige Quest** - die Quest, zu der die Szene gehört. Meist der nützlichere Name: er sagt dir, *was* dich festhält.
- **Zeit in der Szene** - ungefähr wie lange du *in dieser Sitzung* in dieser Szene bist. Mit einem `~` markiert, weil der Mod auf einem Timer prüft. Die Uhr ist Echtzeit nur für den aktuellen Spielstart: **ein Neuladen setzt sie auf null**. Nach dem Neuladen warnt der Mod bei durchgehendem Spiel über dem Schwellenwert weiterhin; kurze Neulade-Schleifen unter dem Schwellenwert addieren frühere Sitzungen nicht.

## Die Anzeige "Editor IDs geladen"

Eine Statusanzeige, kein Schalter - ein Klick bewirkt nichts, außer sie zur Wahrheit zurückzusetzen.

- **Leuchtet** - gut. powerofthree's Tweaks lädt Editor IDs, also erscheinen Szenen und Quests als Namen.
- **Dunkel** - Namen sind aus; alles erscheint stattdessen als ID-Nummer. Der Mod funktioniert in beiden Fällen genau gleich - es ist nur schwerer zu lesen.

Um Namen einzuschalten: öffne `po3_Tweaks.ini` (in deiner powerofthree's-Tweaks-Installation) und setze `Load EditorIDs = true`, dann starte Skyrim neu. Die Anzeige leuchtet auf und die Namen erscheinen.

Der Mod sagt das auch einmal von selbst, sobald er zum ersten Mal bemerkt, dass Namen aus sind. Diese Anzeige ist die dauerhafte Fassung dieser Meldung - das, worauf man in einem Hilfe-Thread zeigen kann, wenn jemand fragt, warum seine Szenen alle nur Nummern sind.

## Aktionen

- **Szene stoppen** - die Behebung. Wenn du wirklich festhängst, beendet das die Szene, in der du bist. Es ist bewusst zweistufig: drücke **Szene stoppen** einmal, um es scharfzustellen (eine Zeile bestätigt, dass es beim Schließen des Menüs stoppt), und drücke erneut, um abzubrechen. Der Stopp selbst passiert in dem Moment, in dem du das Menü schließt, denn nur dann läuft das Spiel genug, damit er greift. Also: scharfstellen, Menü schließen, fertig.

  Greif nur dann dazu, wenn du glaubst, dass die Szene festhängt. Eine normal laufende Szene zu stoppen kann etwas kaputt machen, und eine festhängende zu stoppen kann einen kurzen Schwall verzögerter Ereignisse auslösen, während das Spiel aufholt - das ist zu erwarten, kein neuer Fehler.

- **Aktualisieren** - misst die aktuelle Szene sofort neu, ohne die Seite zu schließen und wieder zu öffnen.

## Letzte Szenen

Die letzten zehn Szenen, die du durchlaufen hast, neueste zuerst, jeweils mit ungefähr ihrer Dauer. Nützlich für "Moment, was war das gerade eben", besonders wenn eine Szene zu schnell vorbeihuscht, um sie zu erfassen.

## Wächter

Der Teil, der wacht, damit du es nicht musst.

- **Warnen nach** - nach wie vielen Minuten in einer einzelnen Szene der Mod dich warnt. Standard ist 3. Auf 0 setzen, um nie zu warnen.
- **Prüfen alle** - wie oft der Wächter nachsieht, in Sekunden. Standard ist 30. Auf 0 setzen, um den Wächter ganz abzuschalten. Das ist für den Fall gedacht, den man erst später bemerkt, es muss also nicht schnell sein: irgendwo zwischen 10 und 240 Sekunden reicht völlig und schont dein Spiel.

Wenn der Wächter auslöst, sind es zwei kurze Zeilen in der Ecke - wie lange du in der Szene bist und dass sie andere blockiert, dann der Name des Mods. Du musst das Menü nicht offen haben, um es zu sehen.

## Beim Arbeiten zusehen (die Diagnoseseite)

- **Wächter** - ein Wort dafür, ob die Hintergrundprüfung gerade läuft: **Läuft**, **Wacht auf** (einen Moment lang nach einem Neuladen normal), **Verspätet** (läuft noch, aber eine Prüfung kam langsamer als ihr Intervall - meist ein Zeichen hoher Skriptlast), **Aus** (du hast Prüfen alle auf 0 gesetzt) oder **Ruht** (auf der Seite Deinstallation abgeschaltet). So bestätigst du, dass der Mod lebt, ohne ein Log zu öffnen.
- **Letzte Selbstreparatur** - der Mod synchronisiert hin und wieder still seinen eigenen Zustand neu, meist direkt nach einem Neuladen - zum Beispiel den Szenen-Timer, damit eine über das Neuladen festhängende Szene nach einer vollen Schwelle durchgehenden Spiels *in dieser Sitzung* noch warnen kann. Diese Neu-Sync **startet** die Stuck-Uhr ab dem Laden neu; Zeit vor dem Laden zählt nicht mit. Eine Zeile hier ist normale Routine, kein Fehler.
- **Diagnoseprotokoll** - wie viel der Mod ins Papyrus-Log schreibt, zur Fehlersuche oder für einen Fehlerbericht:
  - **Aus** - nichts. Der Standard; lass es fürs normale Spielen hier.
  - **Ereignisse** - Szenenwechsel, Warnungen und jedes Mal, wenn der Mod sich selbst korrigiert. Stell das ein, um einen Fehler zu melden.
  - **Jede Prüfung** - fügt bei jeder Abfrage eine Zeile hinzu (der Herzschlag der Schleife, der steigende Timer). Zum Aufspüren eines Timing-Problems, danach wieder zurückstellen.

Das Log landet nur dann auf der Festplatte, wenn die Papyrus-Protokollierung im Spiel eingeschaltet ist. Füge dazu einen `[Papyrus]`-Block zu `Skyrim.ini` (oder `SkyrimCustom.ini`) in `Documents\My Games\Skyrim Special Edition\` hinzu:

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Starte Skyrim neu. Die Datei landet unter `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`; durchsuche sie nach `fth_IJW` (`findstr fth_IJW Papyrus.0.log`, oder `grep`). Mit Mod Organizer 2 ist das dein echter Documents-Ordner, nicht der virtuelle Spielordner.

## Einstellungen

- **Aktuelle Szene benennen** - belege hier eine Taste, und ein Druck darauf zeigt den Namen der Szene an, in der du gerade bist, ganz ohne das Menü zu öffnen. Das schnellste "worin stecke ich gerade".
- **Belegung löschen** - hebt diese Belegung auf. Ein Löschen per ESC gibt es hier nicht (in diesem Menü ist ESC die Pause, und das Spiel warnt dich vor dem Konflikt), also nimmst du eine einmal gesetzte Belegung über diesen Knopf wieder zurück.

## Informationen

Die Version, damit du auf einen Blick siehst, welchen Build du spielst - praktisch, wenn du um Hilfe bittest oder prüfst, ob du auf dem neuesten Stand bist.

## Ausschalten oder entfernen

Du musst nicht deinstallieren, um den Mod anzuhalten. Die Seite **Deinstallation** hat einen einzigen Schalter **Aktiviert**: schalte ihn aus, und der Mod geht in den Ruhezustand - der Wächter hört auf zu prüfen und die Taste wird abgemeldet - ohne dass irgendetwas bereinigt oder dein Spielstand angetastet wird. Schalte ihn wieder ein, wann immer du willst, und er macht genau dort weiter, wo er aufgehört hat. Das ist der schonende Weg, ihn mitten im Spieldurchlauf beiseitezulegen, und ein einfacher Weg zu prüfen, ob er überhaupt je das war, was dich gestört hat.

Wenn du ihn endgültig loswerden willst, entferne ihn in dieser Reihenfolge:

1. **Schalte ihn aus** auf der Seite Deinstallation.
2. **Speichere, dann beende** zum Desktop.
3. **Entferne den Mod** in deinem Mod-Manager (Vortex, MO2 oder von Hand).

Das ist wirklich alles, was nötig ist. Nichts, was dieser Mod tut, beschädigt beim Verlassen einen Spielstand - er hält keine Spielobjekte fest, er blockiert nichts, und nichts anderes hängt von ihm ab. Was er hinterlässt, ist das, was *jeder* skriptbasierte Mod hinterlässt: einen kleinen, inerten Stummel im Spielstand, wo einst sein Skript saß. Skyrim ignoriert ihn. Wenn du auch den noch loswerden willst, kannst du den Stummel mit einem Spielstand-Bereiniger ausfegen, sobald der Mod entfernt ist.

### Über Spielstand-Bereiniger (ReSaver)

Bei einem langen Spielstand lässt du hin und wieder einen Bereiniger laufen - **ReSaver** (Teil von FallrimTools) ist der übliche - um Skript-Müll wegzuräumen, den *andere* Mods hinterlassen haben, die du getauscht oder entfernt hast. Du kannst It Just Works dabei ruhig installiert lassen. Er ist darauf gebaut, eine Bereinigung zu überstehen: ohne Aliase, ohne Weltzustand, selbstheilend. Ein normaler Durchlauf rührt ihn nicht an, und selbst ein aggressiver, der seinen Prüftimer oder seine Taste löscht - er stellt sich beim nächsten Öffnen des Menüs neu scharf. Das Risiko für *diesen* Mod ist so gering, wie es bei einem skriptbasierten Mod nur geht, ganz bewusst.

Die Warnungen, die bleiben, betreffen das Werkzeug, nicht uns: Wisse, was ReSaver tut, bevor du es auf einen Spielstand ansetzt, der dir lieb ist, und ziele auf das, was du tatsächlich entfernt hast, statt blind durchzufegen.
