# Usare It Just Works™

## Cosa fa

Skyrim usa le *scene* per conversazioni, filmati e altri momenti scriptati. A volte una scena non finisce mai. Questo può bloccare in silenzio le scene successive - una missione che non avanza, nessun errore, nessun crash. Questo mod osserva la scena in cui ti trovi, ti avvisa se ci resti da un po', ti mostra di cosa si tratta e ti permette di fermarla se è bloccata.

**Versione breve:** lascia attive le impostazioni predefinite e continua a giocare. Se ricevi un avviso, apri **Menu di configurazione mod > It Just Works**.

Non modifica i record di altri mod né richiede patch, quindi la posizione nell'ordine di caricamento rispetto al tuo stack di contenuti non ha importanza. Non cambierà mai una scena a meno che tu non gli dica di fermarla.

Richiede **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** e **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (con `Load EditorIDs = true` se vuoi i nomi invece dei numeri di ID). Le note di installazione sono sulla [pagina del mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinque pagine: **Scena**, **Sentinella**, **Impostazioni**, **Diagnostica**, **Disinstalla**.

---

## Scena

### In cosa ti trovi

Lettura della scena attuale, oppure **Nessuna**. Il menu si aggiorna all'apertura.

- **Tempo nella scena** - all'incirca da quanto tempo sei in questa scena in questa sessione (tempo reale).
- **Scena** - il nome quando disponibile; altrimenti un numero di ID.
- **Form ID** - l'ID grezzo, sempre mostrato. Utile per la console o una segnalazione di bug.
- **Missione proprietaria** - a quale missione appartiene quella scena.

### Ferma scena

Se credi che la scena sia bloccata, questo la termina.

1. Premi **Ferma scena** una volta - una riga conferma che è armata.
2. Premi di nuovo per annullare, oppure chiudi il menu per fermare.

Ferma solo una scena che ritieni bloccata. Fermarne una normale può rompere qualcosa. Fermarne una bloccata può (raramente) scatenare una breve raffica di eventi ritardati mentre il gioco recupera.

**Aggiorna** rilegge la scena attuale senza chiudere il menu. In Skyrim vanilla, aggiorna difficilmente sarà utile, dato che il gioco è in pausa nei menu. Se usi un mod che toglie la pausa come [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), questo ti permette di aggiornare senza riaprire il menu.

### Scene recenti

Le ultime dieci scene, la più recente per prima, con durata approssimativa.

---

## Sentinella

Controlla al posto tuo.

- **Avvisami dopo** - per quanto tempo una scena può durare prima che tu riceva un avviso. Predefinito **6** minuti. **0** = mai.  
  Niente nel gioco segna una scena come bloccata, e niente nel gioco ci dice per quanto tempo una scena dovrebbe durare. Quindi impostiamo una soglia e ti avvisiamo. Combiniamo tempo di gioco e tempo reale in un modo che speriamo rappresenti all'incirca il "tempo reale passato a giocare davvero", così che il controllo risulti intuitivo.
- **Controlla ogni** - secondi tra i controlli. Predefinito **30**. **0** = spegne la sentinella.
- **Ripeti avvisi** - disattivato per impostazione predefinita, così ricevi un avviso per scena. Attivalo per continuare a ricevere avvisi finché resti oltre la soglia.
- **Ripeti ogni** - minuti tra un avviso e l'altro, usato solo quando ripeti avvisi è attivo. Predefinito **5**.

Un avviso sono due righe nell'angolo, ad esempio:

> scena che blocca le altre ~6m  
> See? It Just Works!

Un avviso per scena per impostazione predefinita, finché non la lasci o la scena cambia. L'hai perso? Apri il menu - la lettura mostra ancora in cosa sei e da quanto tempo. Il mod non ferma la scena al posto tuo; usa Ferma scena nella pagina Scena per farlo.

La sentinella si comporta allo stesso modo sia che i tuoi menu mettano in pausa il mondo (vanilla), sia che lo lascino andare avanti (configurazioni senza pausa come [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859)) - un avviso significa semplicemente che la scena è in corso da un po'.

---

## Impostazioni

- **Abilitata** - attiva per impostazione predefinita. Disattivala per mettere il mod da parte senza disinstallarlo.
- **Leggerezza** - attiva per impostazione predefinita. Le notifiche mantengono un tono leggero; disattivala per un testo semplice. Cambia solo il testo, mai il funzionamento del mod.
- **Lingua delle notifiche** - la lingua delle notifiche del mod nell'angolo. L'installer può impostarla quando scegli una lingua predefinita del menu; cambiala quando vuoi in questa pagina. Inglese per impostazione predefinita e come ripiego; indipendente dall'impostazione della lingua del gioco.
- **Mostra la scena attuale** - assegna un tasto; premilo per vedere il nome della scena attuale senza aprire il menu.
- **Cancella tasto** - rimuove l'assegnazione.
- **Log diagnostico** - quanto viene scritto nel log Papyrus. Lascia **Spento** per il gioco normale. Usa **Eventi** quando segnali un bug; **Ogni controllo** solo se stai rincorrendo un problema di timing, poi rispegnilo. Può influire sulle prestazioni, specialmente a ogni controllo.

  La registrazione funziona solo se il gioco sta scrivendo i log Papyrus. In `Documents\My Games\Skyrim Special Edition\`, modifica `Skyrim.ini` o `SkyrimCustom.ini`:

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Riavvia. File di log: `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Cerca `fth_IJW`.

---

## Diagnostica

- **Editor ID caricati** - un indicatore. Nomi nella pagina Scena e nella missione proprietaria quando acceso; numeri di ID quando spento. Form ID resta comunque l'`0x…` grezzo.

- **Sentinella** - se il controllo in background è attivo:
  - **Attivo** - tutto a posto
  - **In avvio** - normale subito dopo un ricaricamento
  - **In ritardo** - ancora in funzione, ma i controlli sono più lenti del solito (gioco impegnato)
  - **Spento (controlli disattivati)** - hai impostato controlla ogni a 0
  - **Inattivo (spenta)** - abilitata è disattivata in Impostazioni

- **Ultima auto-riparazione** - il mod a volte corregge la propria contabilità (spesso dopo un ricaricamento). Una riga qui è normale.

- **Versione**

---

## Risoluzione dei problemi

### Le scene appaiono come numeri ID, non come nomi

po3 Tweaks non sta caricando gli Editor ID. In `po3_Tweaks.ini`, imposta `Load EditorIDs = true` e riavvia Skyrim; l'indicatore **Editor ID caricati** nella pagina Diagnostica lo conferma. I gestori di mod possono sovrascrivere quel file al deploy o all'aggiornamento, quindi modifica la copia *dentro* il mod Tweaks (o un piccolo mod di override che vince), non solo un file sparso in `Data`:

- **MO2:** la cartella del mod Tweaks nel riquadro sinistro, oppure Overwrite / un mod a priorità più alta.
- **Vortex:** la cartella di staging di Tweaks, oppure un mod di override. Ricontrolla dopo ogni aggiornamento.

Form ID viene mostrato in ogni caso, quindi non resti mai completamente al buio.

### Le notifiche sono nella lingua sbagliata

Le notifiche nell'angolo seguono **Impostazioni > Lingua delle notifiche**, non la lingua del gioco né quale file di traduzione del menu è installato. L'inglese è l'impostazione predefinita e il ripiego.

Una normale esecuzione dell'installer che imposta la lingua predefinita del menu imposta anche questo controllo, così menu e notifiche corrispondono. Se hai solo scambiato il file del menu a mano, oppure hai aggiornato senza rieseguire quel passo dell'installer, imposta una volta la lingua delle notifiche perché corrisponda al tuo menu.

### Il menu è nella lingua sbagliata

Il menu MCM segue l'impostazione della lingua del gioco, non la lingua delle notifiche di cui sopra. Skyrim carica il file di traduzione che corrisponde alla lingua del gioco, quindi un gioco in inglese mostra il menu inglese anche se hai installato un'altra lingua. Due modi per cambiarlo:

- **Installer:** spunta la tua lingua al passo 1, poi scegli quella come lingua predefinita del menu al passo 2. Questo sovrascrive il file del menu inglese (e conserva un `.bak` inglese) **e** imposta la lingua delle notifiche perché corrisponda.
- **A mano:** rinomina `Interface\Translations\fth_ItJustWorks_ITALIAN.txt` in `fth_ItJustWorks_ENGLISH.txt`, sostituendo il file inglese. Questo **non** cambia la lingua delle notifiche - impostala in Impostazioni perché corrisponda, altrimenti le notifiche restano in inglese.

### Il menu o le notifiche mostrano caratteri illeggibili o corrotti

Il testo è corretto - è solo che il tuo gioco non ha alcun font in grado di disegnare quei caratteri, quindi appaiono come caratteri illeggibili. Il font di serie di Skyrim copre le lettere latine e dell'Europa occidentale, ma non il cirillico, il cinese, il giapponese o alcuni segni dell'Europa centrale. Se usi il menu o le notifiche in una di quelle lingue, installa un font mod che le includa; la maggior parte delle configurazioni non inglesi ne ha già uno. Se il tuo non ce l'ha, cerca su Nexus un font che copra la tua lingua - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) è un buon punto di partenza generale.

### Non compare mai un avviso

Controlla lo stato della Sentinella nella pagina Diagnostica, poi le manopole della Sentinella:

- Stato **Inattivo (spenta)** - il mod è spento. Attiva Abilitata (Impostazioni).
- Stato **Spento (controlli disattivati)** - controlla ogni è a 0. Riportalo tra 10 e 240 s.
- Avvisami dopo è a **0** - questo disattiva l'avviso. Imposta i minuti che vuoi.

L'avviso usa il tempo nello stesso modo di avvisami dopo, quindi il tempo nella scena può occasionalmente apparire alto senza un avviso - è normale. È tempo reale e si azzera a un ricaricamento. Anche senza notifica, il menu mostra sempre la scena attuale e da quanto tempo ci sei.

### Ferma scena non ha eliminato la scena

Un arresto non ha mai fallito una sola volta nel prendere effetto, in oltre 10 anni passati a sbloccare salvataggi - prima con versioni grezze una tantum, e ora con questo mod. Quindi se mai segnala che la scena non è finita, hai trovato un bug nel mod, oppure qualcosa di genuinamente nuovo. È emozionante. La sorpresa è il momento in cui si impara. Un log completo è la migliore possibilità di rintracciarne la causa. Attiva la registrazione Papyrus, imposta log diagnostico su **Ogni controllo**, e attiva ogni opzione di log o debug che trovi in tutto il tuo ordine di caricamento, così che, se succede di nuovo, venga catturato. Poi invia il `Papyrus.0.log` completo come segnalazione di bug. Nel frattempo, ricarica da prima del blocco per continuare a giocare.

### Segnalare un bug, o chiedere aiuto

Per un bug, imposta log diagnostico su **Eventi**, riproduci il problema, poi esci. Con la registrazione Papyrus attiva (le righe di `Skyrim.ini` sono sotto Impostazioni), apri `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` e cerca `fth_IJW`. Includi quello, il form ID della scena e la missione proprietaria, e cosa stavi facendo quando si è bloccata.

Dove inviarlo:

- **Segnalazioni di bug:** la [scheda Bugs](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) sulla pagina del mod, oppure [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Domande e aiuto generale:** la [scheda Posts](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) sulla pagina del mod.

---

## Disinstalla

**Rimuoverlo per sempre:**

1. Nella pagina Impostazioni, disattiva Abilitata.
2. Salva, esci al desktop.
3. Rimuovi il mod nel tuo gestore (o a mano).

Sicuro da rimuovere a metà partita. Skyrim può lasciare un piccolo stub di script inerte nel salvataggio, come altri mod scriptati; il gioco lo ignora. Opzionale: un cleaner del salvataggio (es. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** in FallrimTools) può eliminare gli stub dopo la rimozione - usa i cleaner con attenzione, solo su ciò che intendi rimuovere. Puoi lasciare questo mod installato mentre pulisci i residui di *altri* mod.
