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

  Pour activer les noms : dans `po3_Tweaks.ini`, mettez `Load EditorIDs = true`, redémarrez Skyrim. Le mod le dit aussi une fois la première fois qu'il remarque que les noms sont désactivés. Les gestionnaires de mods peuvent écraser ce fichier au déploiement ou à la mise à jour : éditez la copie *dans* le mod Tweaks (ou un petit mod d'override qui gagne), pas seulement un fichier lâche dans `Data`. **MO2 :** dossier du mod dans le volet gauche, ou Overwrite / mod de priorité supérieure. **Vortex :** dossier de staging de Tweaks, ou un mod d'override ; revérifiez après les mises à jour.

- **Surveillance** - si le contrôle en arrière-plan tourne :
  - **En marche** - tout va bien
  - **Réveil en cours** - normal juste après un rechargement
  - **En retard** - toujours actif, mais les vérifications sont plus lentes que d'habitude (jeu chargé)
  - **Désactivée (vérifications coupées)** - vous avez mis **Vérifier toutes les** à 0
  - **En veille (désactivé)** - **Activé** est désactivé sur **Paramètres**

- **Dernière auto-réparation** - le mod corrige parfois sa propre comptabilité (souvent après un rechargement). Une ligne ici est normale.

- **Version**

---

## Désinstallation

**Le retirer pour de bon :**

1. Sur la page **Paramètres**, désactivez **Activé**.
2. Sauvegardez, quittez vers le bureau.
3. Retirez le mod dans votre gestionnaire (ou à la main).

Sûr à retirer en milieu de partie. Skyrim peut laisser un petit stub de script inerte dans la sauvegarde, comme d'autres mods scriptés ; le jeu l'ignore. Optionnel : un nettoyeur de sauvegarde (par ex. **[ReSaver](https://www.nexusmods.com/skyrimspecialedition/mods/5031)** dans FallrimTools) peut effacer les stubs après le retrait - utilisez les nettoyeurs avec précaution, uniquement sur ce que vous vouliez retirer. Vous pouvez laisser ce mod installé tout en nettoyant les résidus d'*autres* mods.
