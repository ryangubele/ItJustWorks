# Utiliser It Just Works™

Tout ce que fait le mod se pilote depuis une seule page : **Menu de configuration des mods > It Just Works**. Voici ce que fait chaque élément.

La version courte, si vous venez de l'installer : ne touchez pas aux valeurs par défaut, continuez à jouer, et laissez la surveillance vous tapoter l'épaule si jamais vous restez trop longtemps dans une scène. Tout ce qui suit est pour quand vous voulez regarder de plus près.

## Afficher le menu en français

Le mod fournit des traductions du menu pour plusieurs langues - choisissez-les dans l'installateur. Skyrim charge la traduction qui correspond au **réglage de langue** de votre jeu ; donc si votre jeu tourne en anglais mais que vous voulez le menu en français, il continue de lire le fichier anglais et le menu reste en anglais, même si la traduction est installée. Deux solutions : dans l'installateur, définissez le français comme **langue par défaut du menu** (il écrit la traduction par-dessus le fichier anglais pour vous) ; ou à la main, renommez votre fichier de langue dans `Interface\Translations\` - `fth_ItJustWorks_FRENCH.txt` - en `fth_ItJustWorks_ENGLISH.txt`, en remplaçant le fichier anglais.

## Scène actuelle

Le haut de la page est un affichage en direct de la scène dans laquelle vous êtes, ou "None" si vous n'êtes dans aucune. Ouvrir la page effectue une nouvelle lecture, elle n'est donc jamais périmée.

- **Scène** - la scène où vous êtes, par son nom (son Editor ID) quand les noms sont disponibles, ou un numéro d'ID brut sinon (voir le témoin ci-dessous).
- **Form ID** - le numéro d'ID brut de la scène, toujours affiché, au cas où vous en auriez besoin pour la console ou un rapport de bug.
- **Quête associée** - la quête à laquelle appartient la scène. Souvent le nom le plus utile : il vous dit *ce qui* vous retient.
- **Temps dans la scène** - environ depuis combien de temps vous êtes dans cette scène. Marqué d'un `~` parce que le mod vérifie sur une minuterie, il connaît donc la réponse à une vérification près.

## Le témoin "Editor ID chargés"

Un témoin d'état, pas un interrupteur - cliquer dessus ne fait rien d'autre que le remettre sur la vérité.

- **Allumé** - bien. powerofthree's Tweaks charge les Editor ID, donc les scènes et les quêtes s'affichent par leur nom.
- **Éteint** - les noms sont désactivés ; tout s'affiche en numéros d'ID à la place. Le mod fonctionne exactement pareil dans les deux cas - c'est juste plus dur à lire.

Pour activer les noms : ouvrez `po3_Tweaks.ini` (dans votre installation de powerofthree's Tweaks) et mettez `Load EditorIDs = true`, puis redémarrez Skyrim. Le témoin s'allume et les noms apparaissent.

Le mod le signale aussi une fois, de lui-même, la première fois qu'il remarque que les noms sont désactivés. Ce témoin est la version permanente de cet avis - la chose à montrer dans un fil d'aide quand quelqu'un demande pourquoi ses scènes ne sont que des numéros.

## Actions

- **Arrêter la scène** - la solution. Si vous êtes vraiment bloqué, ceci met fin à la scène où vous êtes. C'est volontairement en deux temps : appuyez une fois sur **Arrêter la scène** pour l'armer (une ligne confirme qu'elle s'arrêtera à la fermeture du menu), et appuyez de nouveau pour annuler. L'arrêt lui-même se produit au moment où vous fermez le menu, car c'est le seul instant où le jeu tourne assez pour qu'il prenne effet. Donc : armez-le, fermez le menu, c'est fait.

  N'y recourez que si vous pensez que la scène est bloquée. Arrêter une scène qui fonctionne normalement peut casser des choses, et en arrêter une bloquée peut déclencher une brève salve d'événements retardés pendant que le jeu rattrape son retard - c'est attendu, pas un nouveau bug.

- **Actualiser** - effectue tout de suite une nouvelle lecture de la scène actuelle, sans fermer et rouvrir la page.

## Scènes récentes

Les dix dernières scènes que vous avez traversées, la plus récente en premier, chacune avec sa durée approximative. Utile pour "attends, c'était quoi ça à l'instant", surtout quand une scène passe trop vite pour être saisie.

## Surveillance

La partie qui surveille pour que vous n'ayez pas à le faire.

- **M'avertir après** - après combien de minutes dans une même scène le mod vous alerte. Par défaut 3. Mettez 0 pour ne jamais avertir.
- **Vérifier toutes les** - à quelle fréquence la surveillance regarde, en secondes. Par défaut 30. Mettez 0 pour désactiver entièrement la surveillance. C'est prévu pour le cas repéré bien plus tard, ça n'a donc pas besoin d'être rapide : entre 10 et 240 secondes suffit largement, et c'est plus léger pour votre jeu.
- **Journaliser dans Papyrus** - écrit chaque changement de scène dans le journal Papyrus. Laissez-le désactivé sauf si vous dépannez ou remplissez un rapport de bug.

Quand la surveillance se déclenche, ce sont deux courtes lignes dans le coin - depuis combien de temps vous êtes dans la scène et qu'elle en bloque d'autres, puis le nom du mod. Pas besoin d'avoir le menu ouvert pour le voir.

## Paramètres

- **Nommer la scène actuelle** - associez une touche ici, et l'appuyer affiche le nom de la scène où vous êtes, sans ouvrir le menu du tout. Le plus rapide "je suis dans quoi là".
- **Effacer la touche** - dissocie cette touche. Il n'y a pas de "ESC pour effacer" ici (dans ce menu, ESC correspond à Pause, et le jeu vous avertit du conflit), donc c'est avec ce bouton que vous retirez l'association une fois que vous en avez défini une.

## À propos

La version, pour voir d'un coup d'œil quel build vous jouez - pratique quand vous demandez de l'aide ou vérifiez si vous êtes à jour.

## Le désactiver, ou le retirer

Vous n'avez pas besoin de désinstaller pour que le mod s'arrête. La page **Désinstallation** comporte un seul interrupteur **Activé** : désactivez-le et le mod se met en veille - la surveillance cesse de vérifier et la touche est désenregistrée - sans rien nettoyer ni toucher à votre sauvegarde. Réactivez-le quand vous voulez et il reprend exactement là où il s'était arrêté. C'est la façon douce de le mettre de côté en cours de partie, et un moyen facile de vérifier s'il était bien la source de votre problème.

Si vous voulez vraiment vous en débarrasser pour de bon, retirez-le dans cet ordre :

1. **Désactivez-le** sur la page Désinstallation.
2. **Sauvegardez, puis quittez** vers le bureau.
3. **Retirez le mod** dans votre gestionnaire de mods (Vortex, MO2, ou à la main).

C'est vraiment tout ce qu'il faut. Rien de ce que fait ce mod ne cassera une sauvegarde à sa sortie - il ne retient aucun objet du jeu en otage, il ne bloque rien, et rien d'autre ne dépend de lui. Ce qu'il laisse derrière lui, c'est ce que *tout* mod à scripts laisse derrière lui : un petit résidu inerte dans la sauvegarde, là où son script se trouvait. Skyrim l'ignore. Si même cela vous dérange, vous pouvez balayer ce résidu avec un nettoyeur de sauvegarde une fois le mod retiré.

### À propos des nettoyeurs de sauvegarde (ReSaver)

Sur une partie qui dure, vous lancerez un nettoyeur de temps en temps - **ReSaver** (qui fait partie de FallrimTools) est le plus courant - pour éliminer les résidus de scripts laissés par les *autres* mods que vous avez remplacés ou retirés. Vous pouvez laisser It Just Works installé pendant ce temps. Il est conçu pour survivre à un nettoyage : sans alias, sans état du monde, auto-réparant. Une passe normale n'y touchera pas, et même une passe agressive qui efface sa minuterie de vérification ou sa touche, il se réarme dès que vous rouvrez le menu. Le risque pour *ce* mod-ci est à peu près aussi faible que possible pour un mod à scripts, de par sa conception.

Les mises en garde qui subsistent concernent l'outil, pas nous : sachez ce que fait ReSaver avant de le pointer sur une sauvegarde à laquelle vous tenez, et ciblez ce que vous avez réellement retiré plutôt qu'un balayage aveugle.
