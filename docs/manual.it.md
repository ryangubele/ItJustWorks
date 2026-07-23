# Usare It Just Works™

## Cosa fa

Skyrim usa le *scene* per conversazioni, filmati e altri momenti scriptati. A volte una scena non finisce mai. Può bloccare in silenzio le scene successive: una missione che non avanza, nessun errore, nessun crash. Questo mod osserva la scena in cui ti trovi, ti avvisa se ci resti troppo a lungo, ti mostra di cosa si tratta e ti permette di fermarla se è bloccata.

**Versione breve:** lascia le impostazioni predefinite e continua a giocare. Se arriva un avviso, apri **Menu di configurazione mod > It Just Works**.

Richiede **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** e **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` se vuoi i nomi invece dei numeri di ID). Le note di installazione sono sulla [pagina del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinque pagine: **Scena**, **Sentinella**, **Impostazioni**, **Diagnostica**, **Disinstalla**.

---

## Vedere il menu in un'altra lingua

Il mod include traduzioni del menu: sceglile nell'installer. Skyrim carica il file che corrisponde all'**impostazione lingua** del gioco. Un gioco in inglese + un'altra lingua installata continua a leggere il file del menu inglese finché non lo sostituisci.

**Installer:** spunta la lingua al passo 1, poi impostala come lingua predefinita del menu al passo 2 (sovrascrive il file inglese; conserva un `.bak` inglese).

**A mano:** rinomina `Interface\Translations\fth_ItJustWorks_ITALIAN.txt` in `fth_ItJustWorks_ENGLISH.txt` (sostituisci il file inglese).

---

## Scena

### In cosa ti trovi

Lettura in tempo reale della scena attuale, oppure **None**. Apri il menu per una lettura aggiornata.

- **Tempo nella scena** - all'incirca da quanto tempo sei in questa scena; ricaricare il gioco lo azzera. È il segnale bloccato-o-no.
- **Scena** - il nome quando i nomi sono disponibili; altrimenti un numero di ID.
- **Form ID** - l'ID grezzo, sempre mostrato. Utile per la console o una segnalazione di bug.
- **Missione proprietaria** - a quale missione appartiene quella scena.

### Ferma scena

Se credi che la scena sia bloccata, questo la termina.

1. Premi **Ferma scena** una volta: una riga conferma che è armata.
2. Premi di nuovo per annullare, oppure **chiudi il menu** per fermare.

Ferma solo una scena che ritieni bloccata. Fermarne una normale può rompere qualcosa. Fermarne una bloccata può (raramente) scatenare una breve raffica di eventi ritardati mentre il gioco recupera.

**Aggiorna** rilegge la scena attuale senza chiudere il menu. In Skyrim vanilla, il gioco è normalmente in pausa nei menu, quindi **Aggiorna** difficilmente sarà utile. Se usi un mod che toglie la pausa come [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), questo ti permette di aggiornare il menu senza riaprirlo.

### Scene recenti

Le ultime dieci scene, la più recente per prima, con durata approssimativa. Lo stesso tipo di tempo approssimativo di cui sopra.

---

## Sentinella

Controlla al posto tuo.

- **Avvisami dopo** - minuti in una scena prima di un avviso. Predefinito **3**. **0** = non avvisare mai.
- **Controlla ogni** - secondi tra i controlli. Predefinito **30**. **0** = spegne la sentinella.

L'avviso sono due righe nell'angolo, ad esempio:

> scene blocking others ~3m  
> See? It Just Works!

Una volta per scena finché non la lasci o la scena non cambia. Toast perso? Apri il menu: la lettura mostra ancora in cosa sei e da quanto. Il mod non ferma la scena al posto tuo; a quello serve **Ferma scena**.

---

## Impostazioni

- **Abilitata** - accesa in modo predefinito. Spegnila per mettere il mod da parte senza disinstallarlo.
- **Mostra la scena attuale** - assegna un tasto; premilo per vedere il nome della scena attuale senza aprire il menu.
- **Cancella tasto** - rimuove l'assegnazione.
- **Log diagnostico** - quanto va nel log Papyrus. Lascia **Spento** per il gioco normale. Usa **Eventi** quando segnali un bug; **Ogni controllo** solo se rincorri un problema di timing, poi rispegnilo. Può influire sulle prestazioni, soprattutto a **Ogni controllo**.

  La registrazione funziona solo se il gioco scrive i log Papyrus. In `Documents\My Games\Skyrim Special Edition\`, modifica `Skyrim.ini` o `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Riavvia. File di log: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Cerca `fth_IJW`.

---

## Diagnostica

- **Editor ID caricati** - un indicatore. Nomi su **Scena** e missione proprietaria quando accesa; numeri di ID quando spenta. **Form ID** resta l'`0x…` grezzo in ogni caso.

  Per attivare i nomi: in `po3_Tweaks.ini`, imposta `Load EditorIDs = true`, riavvia Skyrim. Il mod lo dice anche una volta la prima volta che nota che i nomi sono disattivati. I gestori di mod possono sovrascrivere quel file al deploy o all'aggiornamento: modifica la copia *dentro* del mod Tweaks (o un piccolo mod di override che vince), non solo un file sparso in `Data`. **MO2:** cartella del mod nel riquadro sinistro, oppure Overwrite / mod a priorità più alta. **Vortex:** cartella di staging di Tweaks, o un mod di override; ricontrolla dopo gli aggiornamenti.

- **Sentinella** - se il controllo in background è attivo:
  - **Attivo** - tutto a posto
  - **In avvio** - normale subito dopo un ricaricamento
  - **In ritardo** - ancora in funzione, ma i controlli sono più lenti del solito (gioco impegnato)
  - **Spento (controlli disattivati)** - hai messo **Controlla ogni** a 0
  - **Inattivo (spenta)** - **Abilitata** è disattivata in **Impostazioni**

- **Ultima auto-riparazione** - il mod a volte corregge la propria contabilità (spesso dopo un ricaricamento). Una riga qui è normale.

- **Versione**

---

## Disinstalla

**Rimuoverlo per sempre:**

1. Nella pagina **Impostazioni**, disattiva **Abilitata**.
2. Salva e esci al desktop.
3. Rimuovi il mod nel tuo gestore (o a mano).

Sicuro da rimuovere a metà partita. Skyrim può lasciare un piccolo stub di script inerte nel salvataggio, come altri mod scriptati; il gioco lo ignora. Opzionale: un cleaner del salvataggio (es. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) può cancellare gli stub dopo la rimozione: usa i cleaner con attenzione, solo su ciò che intendevi rimuovere. Puoi lasciare questo mod installato mentre pulisci i residui di *altri* mod.
