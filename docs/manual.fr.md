# Utiliser It Just Works™

## Ce qu'il fait

Skyrim utilise des *scènes* pour les conversations, les cinématiques et d'autres moments scriptés. Parfois une scène ne se termine jamais. Cela peut bloquer silencieusement les scènes suivantes - une quête qui n'avance plus, aucune erreur, aucun plantage. Ce mod surveille la scène dans laquelle vous êtes, vous avertit si vous y restez trop longtemps, vous montre ce que c'est, et vous laisse l'arrêter si elle est coincée.

**Version courte :** laissez les valeurs par défaut, continuez à jouer. Si une alerte apparaît, ouvrez **Menu de configuration des mods > It Just Works**.

Nécessite **[SKSE64](https://skse.silverlock.org/)**, **[MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)**, **[powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)** et **[powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)** (avec `Load EditorIDs = true` si vous voulez des noms plutôt que des numéros d'ID). Les notes d'installation sont sur la [page du mod](https://www.nexusmods.com/skyrimspecialedition/mods/185927).

Cinq pages : **Scène**, **Surveillance**, **Paramètres**, **Diagnostic**, **Désinstallation**.

---

## Voir le menu dans une autre langue

Le mod livre des traductions de menu - choisissez-les dans l'installateur. Skyrim charge le fichier qui correspond au **réglage de langue** du jeu. Un jeu en anglais + une autre langue installée lit encore le fichier de menu anglais tant que vous ne le remplacez pas.

**Installateur :** cochez la langue à l'étape 1, puis définissez-la comme langue de menu par défaut à l'étape 2 (écrit par-dessus le fichier anglais ; conserve un `.bak` anglais).

**À la main :** renommez `Interface\Translations\fth_ItJustWorks_FRENCH.txt` en `fth_ItJustWorks_ENGLISH.txt` (remplacez le fichier anglais).

---

## Scène

### Ce dans quoi vous êtes

Affichage en direct de la scène actuelle, ou **None**. Ouvrez le menu pour une lecture fraîche.

- **Temps dans la scène** - la ligne qui compte le plus ici : à peu près combien de temps vous y êtes resté cette session (`~` signifie approximatif). C'est le signal coincé-ou-pas. **Recharger le jeu remet ce minuteur à zéro.** Une longue session continue après un rechargement peut encore vous avertir ; enchaîner des rechargements sans rester assez longtemps en jeu, non.
- **Scène** - le nom quand les noms sont disponibles ; sinon un numéro d'ID (voir Editor ID sur Diagnostic).
- **Form ID** - l'ID brut, toujours affiché. Utile pour la console ou un rapport de bug ; vous n'en avez pas besoin pour arrêter la scène - c'est le bouton ci-dessous.
- **Quête associée** - à quelle quête appartient cette scène, quand vous voulez le contexte plus large.

### Arrêter la scène

Si vous croyez que la scène est coincée, cela la termine.

1. Appuyez une fois sur **Arrêter la scène** - une ligne confirme qu'elle est armée.
2. Appuyez de nouveau pour annuler, ou **fermez le menu** pour arrêter. L'arrêt s'exécute à la fermeture du menu.

N'arrêtez qu'une scène que vous croyez coincée. Arrêter une scène normale peut casser des choses. Arrêter une scène coincée peut déclencher une courte salve d'événements retardés pendant que le jeu rattrape - attendu, pas un nouveau problème.

**Actualiser** relit la scène actuelle sans fermer le menu. Ouvrir prend déjà une lecture fraîche ; utilisez ceci si le menu est resté ouvert un moment et que vous voulez une mise à jour - surtout avec des mods comme [Souls](https://www.nexusmods.com/skyrimspecialedition/mods/27859) qui laissent le jeu tourner pendant que les menus sont ouverts.

### Scènes récentes

Les dix dernières scènes, la plus récente en premier, avec une durée approximative. Le même genre de temps approximatif que ci-dessus (un rechargement ne conserve pas de chronomètre des sessions précédentes).

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

- **Activé** - activé par défaut. Désactivez-le pour mettre le mod en veille sans le désinstaller. La surveillance et la touche s'arrêtent ; réactivez-le plus tard et il reprend. Votre sauvegarde est saine.
- **Nommer la scène actuelle** - liez une touche ; appuyez pour voir le nom de la scène actuelle sans ouvrir le menu.
- **Effacer la touche** - retire la liaison. ESC ne l'efface pas ici (ESC est Pause dans ce menu).
- **Journal de diagnostic** - combien part dans le journal Papyrus. Laissez **Désactivé** pour le jeu normal. Utilisez **Événements** pour signaler un bug ; **Chaque vérification** seulement si vous traquez un problème de timing, puis remettez-le.

  La journalisation ne fonctionne que si le jeu écrit des journaux Papyrus. Dans `Documents\My Games\Skyrim Special Edition\`, éditez `Skyrim.ini` ou `SkyrimCustom.ini` :

  ```
  [Papyrus]
  bEnableLogging=1
  bEnableTrace=1
  ```

  Redémarrez. Fichier journal : `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`. Cherchez `fth_IJW`.

---

## Diagnostic

- **Editor ID chargés** - voyant d'état, pas un interrupteur (cliquer le ramène en place).
  - **Allumé** - les noms sont actifs.
  - **Éteint** - vous verrez des numéros d'ID ; le mod fonctionne quand même.

  Pour activer les noms : dans `po3_Tweaks.ini`, mettez `Load EditorIDs = true`, redémarrez Skyrim. Le mod le dit aussi une fois la première fois qu'il remarque que les noms sont désactivés.

- **Surveillance** - si le contrôle en arrière-plan tourne :
  - **En marche** - tout va bien
  - **Réveil en cours** - normal juste après un rechargement
  - **En retard** - toujours actif, mais les vérifications sont plus lentes que d'habitude (jeu chargé)
  - **Désactivée (vérifications coupées)** - vous avez mis Vérifier toutes les à 0
  - **En veille (désactivé)** - Activé est désactivé sur **Paramètres**

- **Dernière auto-réparation** - le mod corrige parfois sa propre comptabilité (souvent après un rechargement). Une ligne ici est normale. Pas une panne, rien à effacer.

- **Version** - numéro de build, pour les fils d'aide et les mises à jour.

---

## Désinstallation

**Le retirer pour de bon :**

1. Sur la page **Paramètres**, désactivez **Activé**.
2. Sauvegardez, quittez vers le bureau.
3. Retirez le mod dans votre gestionnaire (ou à la main).

Sûr à retirer en milieu de partie. Skyrim peut laisser un petit stub de script inerte dans la sauvegarde, comme d'autres mods scriptés ; le jeu l'ignore. Optionnel : un nettoyeur de sauvegarde (par ex. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** dans FallrimTools) peut effacer les stubs après le retrait - utilisez les nettoyeurs avec précaution, uniquement sur ce que vous vouliez retirer. Vous pouvez laisser ce mod installé tout en nettoyant les résidus d'*autres* mods.
