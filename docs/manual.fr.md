# Utiliser It Just Works™

## Ce qu'il fait

Skyrim utilise des *scènes* pour les conversations, les cinématiques et d'autres moments scriptés. Parfois une scène ne se termine jamais. Cela peut bloquer silencieusement les scènes suivantes - une quête qui n'avance plus, aucune erreur, aucun plantage. Ce mod surveille la scène dans laquelle vous êtes, vous avertit si vous y restez trop longtemps, vous montre ce que c'est, et vous laisse l'arrêter si elle est coincée.

**Version courte :** laissez les valeurs par défaut, continuez à jouer. Si une alerte apparaît, ouvrez **Menu de configuration des mods > It Just Works**.

Nécessite **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** et **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (avec `Load EditorIDs = true` si vous voulez des noms plutôt que des numéros d'ID). Les notes d'installation sont sur la [page du mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinq pages : **Scène**, **Surveillance**, **Paramètres**, **Diagnostic**, **Désinstallation**.

---

## Scène

### Ce dans quoi vous êtes

Affichage en direct de la scène actuelle, ou **None**. Ouvrez le menu pour une lecture fraîche.

- **Temps dans la scène** - à peu près combien de temps vous êtes resté dans cette scène ; un rechargement du jeu le remet à zéro. C'est le signal coincé-ou-pas.
- **Scène** - le nom quand les noms sont disponibles ; sinon un numéro d'ID.
- **Form ID** - l'ID brut, toujours affiché. Utile pour la console ou un rapport de bug.
- **Quête associée** - à quelle quête appartient cette scène.

### Arrêter la scène

Si vous croyez que la scène est coincée, cela la termine.

1. Appuyez une fois sur **Arrêter la scène** - une ligne confirme qu'elle est armée.
2. Appuyez de nouveau pour annuler, ou **fermez le menu** pour arrêter.

N'arrêtez qu'une scène que vous croyez coincée. Arrêter une scène normale peut casser des choses. Arrêter une scène coincée peut (rarement) déclencher une courte salve d'événements retardés pendant que le jeu rattrape.

**Actualiser** relit la scène actuelle sans fermer le menu. Dans un Skyrim vanilla, le jeu est normalement en pause dans les menus, donc **Actualiser** a peu de chances d'être utile. Si vous utilisez un mod qui empêche la pause comme [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859), cela vous permet d'actualiser le menu sans le rouvrir.

### Scènes récentes

Les dix dernières scènes, la plus récente en premier, avec une durée approximative. Le même genre de temps approximatif que ci-dessus.

---

## Surveillance

Surveille pour que vous n'ayez pas à le faire.

- **M'avertir après** - minutes dans une scène avant une alerte. Défaut **3**. **0** = ne jamais avertir.
- **Vérifier toutes les** - secondes entre les vérifications. Défaut **30**. **0** = éteindre la surveillance.

L'alerte est deux lignes dans le coin, par exemple :

> scene blocking others ~3m  
> See? It Just Works!

Une fois par scène jusqu'à ce que vous la quittiez ou que la scène change. Toast manqué ? Ouvrez le menu - l'affichage montre encore ce dans quoi vous êtes et depuis combien de temps. Le mod n'arrête pas la scène pour vous ; c'est **Arrêter la scène**.

---

## Paramètres

- **Activé** - activé par défaut. Désactivez-le pour mettre le mod en veille sans le désinstaller.
- **Légèreté** - activé par défaut. Les notifications gardent un ton léger ; désactivez pour un texte neutre. Seul le texte change, jamais le fonctionnement du mod.
- **Langue des notifications** - la langue des notifications contextuelles du mod (les toasts dans le coin). L'installateur peut l'initialiser lorsque vous choisissez une langue de menu par défaut ; modifiez-la à tout moment sur cette page. Anglais par défaut et comme repli ; indépendante du réglage de langue du jeu.
- **Nommer la scène actuelle** - liez une touche ; appuyez pour voir le nom de la scène actuelle sans ouvrir le menu.
- **Effacer la touche** - retire la liaison.
- **Journal de diagnostic** - combien part dans le journal Papyrus. Laissez **Désactivé** pour le jeu normal. Utilisez **Événements** pour signaler un bug ; **Chaque vérification** seulement si vous traquez un problème de timing, puis remettez-le sur Désactivé. Peut affecter les performances, surtout à **Chaque vérification**.

  La journalisation ne fonctionne que si le jeu écrit des journaux Papyrus. Dans `Documents\My Games\Skyrim Special Edition\`, éditez `Skyrim.ini` ou `SkyrimCustom.ini` :

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Redémarrez. Fichier journal : `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Cherchez `fth_IJW`.

---

## Diagnostic

- **Editor ID chargés** - un voyant. Les noms sur **Scène** et la quête associée quand il est allumé ; des numéros d'ID quand il est éteint. Le **Form ID** reste le `0x…` brut dans tous les cas.

- **Surveillance** - si le contrôle en arrière-plan tourne :
  - **En marche** - tout va bien
  - **Réveil en cours** - normal juste après un rechargement
  - **En retard** - toujours actif, mais les vérifications sont plus lentes que d'habitude (jeu chargé)
  - **Désactivée (vérifications coupées)** - vous avez mis **Vérifier toutes les** à 0
  - **En veille (désactivé)** - **Activé** est désactivé sur **Paramètres**

- **Dernière auto-réparation** - le mod corrige parfois sa propre comptabilité (souvent après un rechargement). Une ligne ici est normale.

- **Version**

---

## Dépannage

### Les scènes s'affichent en numéros d'ID, pas en noms

po3 Tweaks ne charge pas les Editor ID. Dans `po3_Tweaks.ini`, mettez `Load EditorIDs = true` et redémarrez Skyrim ; le voyant *Editor ID chargés* de la page **Diagnostic** le confirme. Les gestionnaires de mods peuvent écraser ce fichier au déploiement ou à la mise à jour : éditez donc la copie *dans* le mod Tweaks (ou un petit mod d'override qui gagne), pas seulement un fichier lâche dans `Data` :

- **MO2 :** le dossier du mod Tweaks dans le volet gauche, ou Overwrite / un mod de priorité supérieure.
- **Vortex :** le dossier de staging de Tweaks, ou un mod d'override. Revérifiez après chaque mise à jour.

Le **Form ID** s'affiche dans tous les cas, vous n'êtes donc jamais complètement dans le noir.

### Les notifications sont dans la mauvaise langue

Les toasts dans le coin (l'alerte de scène coincée, l'indice sur les noms, les résultats d'arrêt, l'affichage de la touche de raccourci) suivent **Paramètres > Langue des notifications**, pas la langue du jeu ni le fichier de traduction du menu installé. L'anglais est la valeur par défaut et le repli.

Un lancement normal de l'**installateur** qui définit la langue de menu par défaut initialise aussi ce réglage pour que le menu et les toasts correspondent. Si vous avez seulement remplacé le fichier du menu à la main, ou effectué une mise à jour sans relancer cette étape de l'installateur, réglez une fois la **Langue des notifications** pour qu'elle corresponde à votre menu.

### Le menu est dans la mauvaise langue

Le menu MCM suit le **réglage de langue** du jeu, pas la langue des notifications ci-dessus. Skyrim charge le fichier de traduction qui correspond à la langue du jeu, donc un jeu en anglais affiche le menu anglais même si vous avez installé une autre langue. Deux façons de le changer :

- **Installateur :** cochez votre langue à l'étape 1, puis choisissez-la comme langue de menu par défaut à l'étape 2. Cela écrase le fichier de menu anglais (et conserve un `.bak` anglais) **et** initialise la **Langue des notifications** pour qu'elle corresponde.
- **À la main :** renommez `Interface\Translations\fth_ItJustWorks_FRENCH.txt` en `fth_ItJustWorks_ENGLISH.txt`, en remplaçant le fichier anglais. Cela ne change **pas** la **Langue des notifications** - réglez-la sur **Paramètres** pour qu'elle corresponde, sinon les toasts restent en anglais.

### Le menu ou les notifications affichent des caractères illisibles ou parasités

Le texte est correct - c'est juste que votre jeu n'a aucune police capable de dessiner ces caractères, ils s'affichent donc en charabia. La police d'origine de Skyrim couvre les lettres latines et d'Europe de l'Ouest, mais pas le cyrillique, le chinois, le japonais, ni certains signes d'Europe centrale. Si vous utilisez le menu ou les notifications dans l'une de ces langues, installez un **mod de police** qui les inclut ; la plupart des configurations non anglaises en ont déjà un. Si ce n'est pas votre cas, cherchez sur Nexus une police couvrant votre langue - [Unicode Font](https://www.nexusmods.com/skyrimspecialedition/mods/103346) est un bon point de départ général.

### Aucune alerte n'apparaît jamais

Vérifiez l'état de la **Surveillance** sur la page **Diagnostic**, puis les réglages de **Surveillance** :

- État **En veille (désactivé)** - le mod est éteint. Activez **Activé** (Paramètres).
- État **Désactivée (vérifications coupées)** - **Vérifier toutes les** est à 0. Remettez-le entre 10 et 240 s.
- **M'avertir après** est à **0** - cela désactive l'alerte. Réglez les minutes voulues.

Le **Temps dans la scène** se remet à zéro à un rechargement, donc une scène n'alerte qu'une fois que vous y êtes resté, sans interruption, au-delà du délai d'avertissement pendant cette session. Même sans toast, le menu montre toujours la scène actuelle et depuis combien de temps vous y êtes.

### Arrêter la scène n'a pas dissipé la scène

Un arrêt n'a jamais échoué à prendre - pas en 14 ans à décoincer des sauvegardes, d'abord avec des versions rudimentaires ponctuelles et maintenant avec celle-ci. Donc s'il signale un jour que la scène ne s'est pas terminée, vous avez trouvé quelque chose de vraiment nouveau - ce qui est excitant, pas alarmant. La surprise, c'est là qu'on apprend. Il n'y a pas encore de cause connue, et rien n'est promis, mais un journal complet est la meilleure chance d'en trouver une. Activez la journalisation Papyrus, réglez **Paramètres > Journal de diagnostic** sur **Chaque vérification**, et activez toutes les options de journal ou de débogage que vous trouvez dans tout votre ordre de chargement - pour que, si cela se reproduit, ce soit capturé. Puis envoyez le `Papyrus.0.log` complet comme rapport de bug (canaux ci-dessous). Rechargez d'avant le blocage pour continuer à jouer entre-temps.

### Signaler un bug, ou demander de l'aide

Pour un bug, réglez **Paramètres > Journal de diagnostic** sur **Événements**, reproduisez le problème, puis quittez. Avec la journalisation Papyrus activée (les lignes `Skyrim.ini` sont sous **Paramètres**), ouvrez `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` et cherchez `fth_IJW`. Incluez cela, le **Form ID** et la **Quête associée** de la scène, et ce que vous faisiez au moment du blocage.

Où l'envoyer :

- **Rapports de bug :** [Bugs tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=bugs) sur la page du mod, ou [GitHub Issues](https://github.com/ryangubele/ItJustWorks/issues).
- **Questions et aide générale :** [Posts tab](https://www.nexusmods.com/skyrimspecialedition/mods/185927?tab=posts) sur la page du mod.

---

## Désinstallation

**Le retirer pour de bon :**

1. Sur la page **Paramètres**, désactivez **Activé**.
2. Sauvegardez, quittez vers le bureau.
3. Retirez le mod dans votre gestionnaire (ou à la main).

Sûr à retirer en milieu de partie. Skyrim peut laisser un petit stub de script inerte dans la sauvegarde, comme d'autres mods scriptés ; le jeu l'ignore. Optionnel : un nettoyeur de sauvegarde (par ex. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** dans FallrimTools) peut effacer les stubs après le retrait - utilisez les nettoyeurs avec précaution, uniquement sur ce que vous vouliez retirer. Vous pouvez laisser ce mod installé tout en nettoyant les résidus d'*autres* mods.
