# Usare It Just Works™

## Cosa fa

Skyrim usa le *scene* per conversazioni, filmati e altri momenti scriptati. A volte una scena non finisce mai. Può bloccare in silenzio le scene successive: una missione che non avanza, nessun errore, nessun crash. Questo mod osserva la scena in cui ti trovi, ti avvisa se ci resti troppo a lungo, ti mostra di cosa si tratta e ti permette di fermarla se è bloccata.

**Versione breve:** lascia le impostazioni predefinite e continua a giocare. Se arriva un avviso, apri **Menu di configurazione mod > It Just Works**.

Richiede **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** e **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` se vuoi i nomi invece dei numeri di ID). Le note di installazione sono sulla [pagina del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Tre pagine nel menu: **Scena**, **Diagnostica**, **Disinstalla**.

---

## Vedere il menu in un'altra lingua

Il mod include traduzioni del menu: sceglile nell'installer. Skyrim carica il file che corrisponde all'**impostazione lingua** del gioco. Un gioco in inglese + un'altra lingua installata continua a leggere il file del menu inglese finché non lo sostituisci.

**Installer:** spunta la lingua al passo 1, poi impostala come lingua predefinita del menu al passo 2 (sovrascrive il file inglese; conserva un `.bak` inglese).

**A mano:** rinomina `Interface\Translations\fth_ItJustWorks_ITALIAN.txt` in `fth_ItJustWorks_ENGLISH.txt` (sostituisci il file inglese).

---

## Scena

### In cosa ti trovi

Lettura in tempo reale della scena attuale, oppure **None**. Apri il menu per una lettura aggiornata.

- **Tempo nella scena** - la riga che di solito conta qui: circa quanto tempo ci sei rimasto in questa sessione (`~` significa approssimativo). È il segnale bloccato-o-no. **Ricaricare il gioco azzera questo timer.** Un tratto lungo di gioco continuo dopo un ricaricamento può ancora avvisarti; passare da un ricaricamento all'altro senza restare abbastanza in gioco, no.
- **Scena** - il nome quando i nomi sono disponibili; altrimenti un numero di ID (vedi Editor ID in Diagnostica).
- **Form ID** - l'ID grezzo, sempre mostrato. Utile per la console o una segnalazione di bug; non ti serve per fermare la scena: a quello serve il pulsante sotto.
- **Missione proprietaria** - a quale missione appartiene quella scena, quando vuoi il contesto più ampio.

### Ferma scena

Se credi che la scena sia bloccata, questo la termina.

1. Premi **Ferma scena** una volta: una riga conferma che è armata.
2. Premi di nuovo per annullare, oppure **chiudi il menu** per fermare. L'arresto avviene alla chiusura del menu.

Ferma solo una scena che ritieni bloccata. Fermarne una normale può rompere qualcosa. Fermarne una bloccata può scatenare una breve raffica di eventi ritardati mentre il gioco recupera: atteso, non un problema nuovo.

**Aggiorna** rilegge la scena attuale senza chiudere il menu. Aprire già prende una lettura fresca; usalo se hai tenuto il menu aperto a lungo e vuoi un aggiornamento, soprattutto con mod come [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859) che tengono il gioco in esecuzione mentre i menu sono aperti.

### Scene recenti

Le ultime dieci scene, la più recente per prima, con durata approssimativa. Lo stesso tipo di tempo approssimativo di cui sopra (un ricaricamento non conserva un cronometro delle sessioni precedenti).

### Sentinella

Nella stessa pagina. Controlla al posto tuo.

- **Avvisami dopo** - minuti in una scena prima di un avviso. Predefinito **3**. **0** = non avvisare mai.
- **Controlla ogni** - secondi tra i controlli. Predefinito **30**. **0** = spegne la sentinella.

L'avviso sono due righe nell'angolo, ad esempio:

> scene blocking others ~3m  
> See? It Just Works!

Una volta per scena finché non la lasci o la scena non cambia. Toast perso? Apri il menu: la lettura mostra ancora in cosa sei e da quanto. Il mod non ferma la scena al posto tuo; a quello serve **Ferma scena**.

### Hotkey

- **Mostra la scena attuale** - assegna un tasto; premilo per vedere il nome della scena attuale senza aprire il menu.
- **Cancella tasto** - rimuove l'assegnazione. ESC non la cancella qui (ESC è Pausa in questo menu).

---

## Diagnostica

- **Editor ID caricati** - spia di stato, non un interruttore (cliccandola torna al posto).
  - **Accesa** - i nomi sono attivi.
  - **Spenta** - vedrai numeri di ID; il mod funziona comunque.

  Per attivare i nomi: in `po3_Tweaks.ini`, imposta `Load EditorIDs = true`, riavvia Skyrim. Il mod lo dice anche una volta la prima volta che nota che i nomi sono disattivati.

- **Sentinella** - se il controllo in background è attivo:
  - **Attivo** - tutto a posto
  - **In avvio** - normale subito dopo un ricaricamento
  - **In ritardo** - ancora in funzione, ma i controlli sono più lenti del solito (gioco impegnato)
  - **Spento (controlli disattivati)** - hai messo Controlla ogni a 0
  - **Inattivo (spenta)** - Abilitata è disattivata in Disinstalla

- **Ultima auto-riparazione** - il mod a volte corregge la propria contabilità (spesso dopo un ricaricamento). Una riga qui è normale. Non è un guasto e non c'è nulla da cancellare.

- **Log diagnostico** - quanto va nel log Papyrus. Lascia **Spento** per il gioco normale. Usa **Eventi** quando segnali un bug; **Ogni controllo** solo se rincorri un problema di timing, poi rimettilo.

  La registrazione funziona solo se il gioco scrive i log Papyrus. In `Documents\My Games\Skyrim Special Edition\`, modifica `Skyrim.ini` o `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Riavvia. File di log: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Cerca `fth_IJW`.

- **Versione** - numero di build, per thread di aiuto e aggiornamenti.

---

## Spegnere o rimuovere

**Metterlo da parte:** pagina Disinstalla → **Abilitata** disattivata. Sentinella e hotkey si fermano; riattivalo più tardi e riprende. Il salvataggio è a posto.

**Rimuoverlo per sempre:**

1. Disattiva **Abilitata**.
2. Salva e esci al desktop.
3. Rimuovi il mod nel tuo gestore (o a mano).

Sicuro da rimuovere a metà partita. Skyrim può lasciare un piccolo stub di script inerte nel salvataggio, come altri mod scriptati; il gioco lo ignora. Opzionale: un cleaner del salvataggio (es. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) può cancellare gli stub dopo la rimozione: usa i cleaner con attenzione, solo su ciò che intendevi rimuovere. Puoi lasciare questo mod installato mentre pulisci i residui di *altri* mod.
