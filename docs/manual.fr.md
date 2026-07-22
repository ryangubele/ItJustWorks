# Utiliser It Just Works™

## Ce qu'il fait, et pourquoi

Skyrim fonctionne à base de *scènes* - des moments scriptés comme les conversations et les cinématiques, censés se terminer d'eux-mêmes. Parfois l'une d'elles ne se termine pas, et une scène bloquée peut silencieusement empêcher celles qui suivent, cassant discrètement une quête ou même une sauvegarde entière, sans la moindre erreur pour vous prévenir. Ce mod surveille la scène dans laquelle vous êtes et vous alerte si vous y restez bloqué trop longtemps, vous montre dans un menu celle où vous êtes, et vous laisse arrêter une scène qui est coincée. C'est toute l'idée : repérer l'interrupteur resté coincé avant qu'il ne vous coûte la sauvegarde.

Tout ce que fait le mod se pilote depuis une seule page : **Menu de configuration des mods > It Just Works**. Voici ce que fait chaque élément.

La version courte, si vous venez de l'installer : ne touchez pas aux valeurs par défaut, continuez à jouer, et laissez la surveillance vous tapoter l'épaule si jamais vous restez trop longtemps dans une scène. Tout ce qui suit est pour quand vous voulez regarder de plus près.

## Afficher le menu en français

Le mod fournit des traductions du menu pour plusieurs langues - choisissez-les dans l'installateur. Skyrim charge la traduction qui correspond au **réglage de langue** de votre jeu ; donc si votre jeu tourne en anglais mais que vous voulez le menu en français, il continue de lire le fichier anglais et le menu reste en anglais, même si la traduction est installée. Deux solutions : dans l'installateur, cochez cette langue à la première étape, puis choisissez-la comme **langue par défaut du menu** à la deuxième (il écrit la traduction par-dessus le fichier anglais pour vous, et conserve un fichier anglais `.bak` que vous pouvez renommer pour revenir en arrière) ; ou à la main, renommez le fichier de votre langue dans `Interface\Translations\` - `fth_ItJustWorks_FRENCH.txt` - en `fth_ItJustWorks_ENGLISH.txt`, en remplaçant le fichier anglais.

## Scène actuelle

Le haut de la page est un affichage en direct de la scène dans laquelle vous êtes, ou "None" si vous n'êtes dans aucune. Ouvrir la page effectue une nouvelle lecture, elle n'est donc jamais périmée.

- **Scène** - la scène où vous êtes, par son nom (son Editor ID) quand les noms sont disponibles, ou un numéro d'ID brut sinon (voir le témoin ci-dessous).
- **Form ID** - le numéro d'ID brut de la scène, toujours affiché, au cas où vous en auriez besoin pour la console ou un rapport de bug.
- **Quête associée** - la quête à laquelle appartient la scène. Souvent le nom le plus utile : il vous dit *ce qui* vous retient.
- **Temps dans la scène** - environ depuis combien de temps vous êtes dans cette scène *cette session*. Marqué d'un `~` parce que le mod vérifie sur un minuteur. L'horloge est le temps réel du lancement actuel seulement : **un rechargement la remet à zéro**. Après rechargement, un jeu continu au-delà du seuil d'alerte avertit encore ; de courts rechargements sous le seuil n'additionnent pas les sessions précédentes.

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

Quand la surveillance se déclenche, ce sont deux courtes lignes dans le coin - depuis combien de temps vous êtes dans la scène et qu'elle en bloque d'autres, puis le nom du mod. Pas besoin d'avoir le menu ouvert pour le voir.

## Le voir travailler (la page Diagnostic)

- **Surveillance** - un seul mot pour dire si la vérification en arrière-plan tourne en ce moment : **En marche**, **Réveil en cours** (normal un instant juste après un rechargement), **En retard** (toujours actif, mais une vérification est arrivée plus lentement que son intervalle - en général signe d'une forte charge de scripts), **Désactivée** (vous avez mis Vérifier toutes les à 0), ou **En veille** (désactivée sur la page Désinstallation). C'est ainsi que vous confirmez que le mod est vivant sans ouvrir de journal.
- **Dernière auto-réparation** - le mod resynchronise discrètement son propre état de temps en temps, le plus souvent juste après un rechargement - par exemple le minuteur de scène, pour qu'une scène bloquée à travers un reload puisse encore alerter après un seuil complet de jeu continu *cette session*. Cette resynchro **redémarre** l'horloge depuis le chargement ; le temps d'avant ne s'ajoute pas. Une ligne ici est de l'entretien normal, pas une panne.
- **Journal de diagnostic** - la quantité de ce que le mod écrit dans le journal Papyrus, pour dépanner ou remplir un rapport de bug :
  - **Désactivé** - rien. La valeur par défaut ; laissez-le ici pour jouer normalement.
  - **Événements** - changements de scène, alertes, et chaque fois que le mod se corrige. Mettez-le là pour remplir un rapport de bug.
  - **Chaque vérification** - ajoute une ligne à chaque passage (le battement de cœur de la boucle, la minuterie qui grimpe). Pour traquer un problème de timing, puis remettez-le comme avant.

Le journal n'atteint le disque que si la journalisation Papyrus est activée dans le jeu. Ajoutez un bloc `[Papyrus]` à `Skyrim.ini` (ou `SkyrimCustom.ini`) dans `Documents\My Games\Skyrim Special Edition\` :

```
[Papyrus]
bEnableLogging=1
bEnableTrace=1
```

Redémarrez Skyrim. Le fichier apparaît dans `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` ; cherchez-y `fth_IJW` (`findstr fth_IJW Papyrus.0.log`, ou `grep`). Avec Mod Organizer 2, c'est votre vrai dossier Documents, pas le dossier de jeu virtuel.

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
