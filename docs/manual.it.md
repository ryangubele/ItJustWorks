# Usare It Just Works™

## Cosa fa, e perché

Skyrim gira sulle *Scene* - momenti scriptati come conversazioni e filmati che dovrebbero concludersi da soli. A volte una non lo fa, e una scena bloccata può silenziosamente impedire a quelle successive di partire, rompendo in sordina una missione o persino un intero salvataggio senza alcun errore a preavvisarti. Questa mod tiene d'occhio la scena in cui ti trovi e ti avvisa se ci sei rimasto bloccato troppo a lungo, ti mostra da un menu in cosa sei, e ti permette di fermare una scena che si è inceppata. È tutta qui l'idea: cogliere l'interruttore bloccato prima che ti costi il salvataggio.

Tutto ciò che fa la mod si gestisce da un'unica pagina: **Menu di Configurazione della Mod > It Just Works**. Ecco cosa fa ogni parte.

La versione breve, se l'hai appena installata: lascia stare i valori predefiniti, continua a giocare, e lascia che la sentinella ti dia un colpetto sulla spalla se mai resti troppo a lungo in una scena. Tutto il resto qui sotto è per quando vuoi guardare più da vicino.

## Vedere il menu in italiano

La mod include traduzioni del menu per diverse lingue - scegliile nell'installer. Skyrim carica la traduzione che corrisponde all'**impostazione della lingua** del gioco; quindi se il gioco è in inglese ma vuoi il menu in italiano, continua a leggere il file inglese e il menu resta in inglese anche se la traduzione è installata. Due soluzioni: nell'installer, spunta quella lingua nel primo passaggio, poi scegliela come **lingua predefinita del menu** nel secondo (scrive la traduzione sopra il file inglese al posto tuo, e conserva un `.bak` inglese che puoi rinominare per ripristinarlo); oppure a mano, rinomina il tuo file di lingua in `Interface\Translations\` - `fth_ItJustWorks_ITALIAN.txt` - in `fth_ItJustWorks_ENGLISH.txt`, sostituendo quello inglese.

## Scena attuale

La parte alta della pagina è una lettura dal vivo della scena in cui ti trovi, o "None" se non sei in nessuna. Aprire la pagina esegue una nuova lettura, quindi non è mai obsoleta.

- **Scena** - la scena in cui sei, per nome (il suo Editor ID) quando i nomi sono disponibili, o un numero ID grezzo quando non lo sono (vedi la spia qui sotto).
- **Form ID** - il numero ID grezzo della scena, sempre mostrato, nel caso ti serva per la console o una segnalazione di bug.
- **Missione proprietaria** - la missione a cui appartiene la scena. Di solito il nome più utile: ti dice *cosa* ti sta trattenendo.
- **Tempo nella scena** - all'incirca da quanto sei in questa scena *in questa sessione*. Contrassegnato con `~` perché la mod controlla su un timer. L'orologio è tempo reale solo del lancio attuale: **un ricaricamento lo azzera**. Dopo il reload, il gioco continuo oltre la soglia di avviso avvisa ancora; ricaricamenti brevi sotto soglia non sommano le sessioni precedenti.

## La spia "Editor ID caricati"

Una spia di stato, non un interruttore - cliccarla non fa altro che riportarla alla verità.

- **Accesa** - bene. powerofthree's Tweaks sta caricando gli Editor ID, quindi scene e missioni compaiono per nome.
- **Spenta** - i nomi sono disattivati; tutto compare come numeri ID invece. La mod funziona esattamente allo stesso modo in entrambi i casi - è solo più difficile da leggere.

Per attivare i nomi: apri `po3_Tweaks.ini` (nella tua installazione di powerofthree's Tweaks) e imposta `Load EditorIDs = true`, poi riavvia Skyrim. La spia si accende e i nomi compaiono.

La mod lo segnala anche una volta, da sola, la prima volta che nota che i nomi sono disattivati. Questa spia è la versione permanente di quell'avviso - la cosa da indicare in un thread di aiuto quando qualcuno chiede perché le sue scene sono tutte numeri.

## Azioni

- **Ferma scena** - la soluzione. Se sei davvero bloccato, questo termina la scena in cui sei. È volutamente in due passi: premi **Ferma scena** una volta per armarlo (compare una riga che conferma che si fermerà alla chiusura del menu) e premi di nuovo per annullare. L'arresto vero e proprio avviene nel momento in cui chiudi il menu, perché è l'unico istante in cui il gioco gira abbastanza da farlo valere. Quindi: armalo, chiudi il menu, fatto.

  Ricorri a questo solo se pensi che la scena sia bloccata. Fermare una scena che funziona normalmente può rompere qualcosa, e fermarne una bloccata può scatenare una breve raffica di eventi ritardati mentre il gioco recupera - è previsto, non è un nuovo bug.

- **Aggiorna** - esegue subito una nuova lettura della scena attuale, senza chiudere e riaprire la pagina.

## Scene recenti

Le ultime dieci scene che hai attraversato, la più recente per prima, ciascuna con la durata approssimativa. Utile per "aspetta, cos'era quella cosa di poco fa", specie quando una scena passa troppo in fretta per coglierla.

## Sentinella

La parte che sorveglia così non devi farlo tu.

- **Avvisami dopo** - dopo quanti minuti in una singola scena la mod ti avvisa. Predefinito 3. Imposta 0 per non avvisare mai.
- **Controlla ogni** - ogni quanto guarda la sentinella, in secondi. Predefinito 30. Imposta 0 per spegnere del tutto la sentinella. È pensato per il caso che ci si accorge molto dopo, quindi non serve che sia veloce: da 10 a 240 secondi basta e avanza, ed è più leggero per il tuo gioco.

Quando la sentinella scatta, sono due brevi righe nell'angolo - da quanto sei nella scena e che ne sta bloccando altre, poi il nome della mod. Non serve avere il menu aperto per vederlo.

## Guardarla lavorare (la pagina Diagnostica)

- **Sentinella** - una sola parola per dire se il controllo in background è attivo in questo momento: **Attivo**, **In avvio** (normale per un istante subito dopo un caricamento), **In ritardo** (ancora attivo, ma un controllo è arrivato più lentamente del suo intervallo - di solito segno di un carico di script elevato), **Spento** (hai impostato Controlla ogni a 0), o **Inattivo** (spenta dalla pagina Disinstalla). È così che confermi che la mod è viva senza aprire un log.
- **Ultima auto-riparazione** - ogni tanto la mod risincronizza in sordina il proprio stato, il più delle volte subito dopo un ricaricamento - ad esempio il timer scena, così una scena bloccata attraverso un reload può ancora avvisare dopo una soglia piena di gioco continuo *in questa sessione*. Quella risync **riavvia** l'orologio dal caricamento; non somma il tempo precedente. Una riga qui è manutenzione normale, non un guasto.
- **Log diagnostico** - quanto la mod scrive nel log di Papyrus, per la diagnostica o una segnalazione di bug:
  - **Spento** - niente. Il valore predefinito; lascialo qui per il gioco normale.
  - **Eventi** - cambi di scena, avvisi e ogni volta che la mod si corregge. Imposta questo per segnalare un bug.
  - **Ogni controllo** - aggiunge una riga a ogni controllo (il battito del ciclo, il timer che sale). Per inseguire un problema di tempistica, poi rimettilo com'era.

Il log arriva su disco solo se la registrazione di Papyrus è attiva nel gioco. Aggiungi un blocco `[Papyrus]` a `Skyrim.ini` (o `SkyrimCustom.ini`) in `Documents\My Games\Skyrim Special Edition\`:

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Riavvia Skyrim. Il file compare in `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`; cerca `fth_IJW` al suo interno (`findstr fth_IJW Papyrus.0.log`, o `grep`). Con Mod Organizer 2 quella è la tua vera cartella Documents, non la cartella di gioco virtuale.

## Impostazioni

- **Mostra la scena attuale** - assegna un tasto qui, e premerlo mostra il nome della scena in cui sei, senza aprire affatto il menu. Il più rapido "in cosa sono adesso".
- **Cancella tasto** - rimuove l'assegnazione di quel tasto. Qui non c'è un ESC per cancellare (in questo menu ESC è Pausa, e il gioco ti avvisa del conflitto), quindi è con questo pulsante che togli l'assegnazione una volta che ne hai impostata una.

## Informazioni

La versione, così vedi a colpo d'occhio quale build stai giocando - comodo quando chiedi aiuto o controlli se sei aggiornato.

## Spegnerla, o rimuoverla

Non devi disinstallarla per fermare la mod. La pagina **Disinstalla** ha un solo interruttore **Abilitata**: spegnilo e la mod diventa inattiva - la sentinella smette di controllare e il tasto viene deregistrato - senza ripulire nulla né toccare il tuo salvataggio. Riaccendila quando vuoi e riprende esattamente da dove aveva lasciato. È il modo garbato di metterla da parte a metà partita, e un modo facile per verificare se era proprio lei a darti fastidio.

Se invece la vuoi via per sempre, rimuovila in quest'ordine:

1. **Spegnila** nella pagina Disinstalla.
2. **Salva, poi esci** al desktop.
3. **Rimuovi la mod** nel tuo gestore di mod (Vortex, MO2, o a mano).

È davvero tutto ciò che serve. Niente di ciò che fa questa mod rovinerà un salvataggio all'uscita - non tiene in ostaggio alcun oggetto di gioco, non blocca nulla, e niente dipende da lei. Ciò che lascia dietro di sé è ciò che lascia *ogni* mod con script: un piccolo residuo inerte nel salvataggio dove viveva il suo script. Skyrim lo ignora. Se vuoi eliminare anche quello, puoi spazzare via il residuo con un pulitore di salvataggi una volta rimossa la mod.

### Sui pulitori di salvataggi (ReSaver)

Con un salvataggio di lunga data, ogni tanto eseguirai un pulitore - **ReSaver** (parte di FallrimTools) è quello di prassi - per rimuovere i residui di script lasciati da *altre* mod che hai sostituito o rimosso. Puoi lasciare It Just Works installata mentre lo fai. È costruita per sopravvivere a una pulizia: senza alias, nessuno stato del mondo, si ripara da sola. Un passaggio normale non la tocca, e anche uno aggressivo che ne cancella il timer di controllo o il tasto si riarma la volta successiva che apri il menu. Il rischio per *questa* mod è basso quanto può esserlo per una mod con script, per come è progettata.

Le cautele che restano riguardano lo strumento, non noi: sappi cosa fa ReSaver prima di puntarlo a un salvataggio a cui tieni, e mira a ciò che hai davvero rimosso invece di uno spazzamento alla cieca.
