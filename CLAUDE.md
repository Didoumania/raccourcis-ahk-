# raccourcis-ahk (barres de raccourcis sur l'écran)

Deux barres de boutons de raccourcis sur les bords de l'écran (gauche et droite), écrites en AutoHotkey v2 pour Windows : captures d'écran vers Claude, copier/coller, zoom, clavier visuel, etc. Lire `README.md` en premier.

## Contenu
- `raccourcis.ahk` : le script principal (environ 600 lignes).
- `lanceur_demarrage.ahk` : lance le script 5 secondes après l'ouverture de Windows. Le chemin qu'il contient est à adapter à la machine.

## Utilisation
1. Installer AutoHotkey v2.
2. Double-cliquer sur `raccourcis.ahk`.
3. Pour le démarrage automatique : mettre une copie de `lanceur_demarrage.ahk` dans le dossier de démarrage (Win+R, puis `shell:startup`).

## Règles de travail
- Syntaxe AutoHotkey **v2** uniquement (pas v1).
- Avant de modifier `raccourcis.ahk`, garder une copie de la version qui marche : ce script est utilisé tous les jours.
- Ne rien supprimer ni déplacer sans demande explicite.
- Dépôt **public** : n'y mettre aucun mot de passe, token ni chemin personnel sensible.

## Où on en est
- Au 25/11/2026 : `raccourcis.ahk` est la version du Shadow (boutons FERMER, CTRL+S, SAUVER+FERMER, réponses aux commentaires, smiley « Regarde »). L'ancienne version est dans `Versions/raccourcis_version_avant.ahk`. Le lanceur ouvre `Bureau\Raccourcis Claude\raccourcis.ahk`.
