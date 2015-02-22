* Essayer de définir la taille du PNG que sort Lilypond
  => dresolution
  > Ajouter un menu en admin

* Automator pour faire le fichier SON (depuis le AIFF jusqu'au MP3 dans un bon dossier où le fichier sera automatiquement chargé — cf. ci-dessous)

* Un dossier son où sont automatiquement téléchargé les fichiers mp3 quand on en trouve. Noter qu'ils doivent être téléchargés sur Icare, par sur Piano (donc ssh propre)

* [SCORE]
  - Section administration : seulement en online pour qu'il n'y ait pas de conflit de pstore.
  - [CRON] "nettoyer" le pstore : il passe en revue les src, les checks par curl et détruit celles qui n'existent plus.
  - un bouton pour renoncer et détruire l'image
  - Expliquer dans le manuel comment on crée une image avec l'interface. 
    > Expliquer comment la modifier (en gardant simplement le même nom)
  - Pouvoir piocher une image existante, à commencer par celles de l'article courant
  DOCUMENTER :
    - `o{texte}' pour entourer
    - `b{texte}` pour entourer (b{texte}b pour étirer jusqu'à note suivante)
    - `ton{<ton>}` pour définir la tonalité (= mod)
    - `mod{<ton>}` pour marquer une modulation dans <ton>
    - `emp{<ton>}` pour marquer un emprunt tonal à <ton>
    
[CRON]
  - Voir ce qu'il faut faire quand le nombre de reader est différent du nombre d'IPs, peut-être qu'il faut essayer de trouver l'information manquante.

* Image pour le prélude Cm de Bach étudié avec Isabelle
<img src='http://icare.alwaysdata.net/img/cp_score/bach/preludeCm-01.png' />

* Explication gamme

Chaque note de musique a un NOM —&nbsp;do, ré, mi, fa, etc.&nbsp;— et une NATURE —&nbsp;bécarre, bémol, dièse, double-bémol, etc.&nbsp;.

Tout comme les notes, les intervalles ont des NOMS —&nbsp;qui ne dépendent <u>que</u> des noms des notes&nbsp;— et des NATURES —&nbsp;qui dépendent de la nature des notes.

SCORE
