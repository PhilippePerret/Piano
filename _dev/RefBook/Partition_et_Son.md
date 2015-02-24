#Partitions

Un des plus (+) les plus importants du site est le recours dans les explications à des partitions pour la plupart sonores.

* [Fabriquer la partition](#fabriquer_la_partition)
* [Fabrication d'une partition sonore](#fabrication_dune_image_sonore)
* [Créer le fichier son](#creer_le_fichier_son)
* [Insertion dans la page ou le texte](#insertion_dans_la_page_ou_le_texte)
  * [Partition avec “bouton” pour lancer le son](#partition_avec_bouton_pour_lancer_le_son)
  * [Mot du texte de l'article déclenchant le son d'une image](#inserer_mot_declenchant_une_image)
  * [Mot du texte déclenchant un son sans image](#mot_du_texte_declenchant_son_sans_image)
* [Gestion du pstore des scores](#gestion_dans_pstore_scores)
* [[PROGRAMME] Modification du traitement des notes](#modify_traitement_note)




<a name='insertion_dans_la_page_ou_le_texte'></a>
##Insertion dans la page ou le texte

<a name='partition_avec_bouton_pour_lancer_le_son'></a>
###Partition avec “bouton” pour lancer le son

    <%= image('path/to/image', center: true, mp3: 'path/to/son') %>

Ce code produit une image de la partition, avec le mot "Écouter" placé à côté pour lancer le son associé.

Note&nbsp;: Le `path/to/son` est à considérer depuis `sound/cp/` sur l'atelier Icare. Le plus simple, si une page doit utiliser plusieurs son du dossier, de définir&nbsp;:

    <% rep_son = "path/to/folder" %>

… puis d'utiliser dans la donnée `:mp3`&nbsp;:

    <%= image(.... mp3: "#{rep_son}/son")

*Noter que l'extension “.mp3” n'est pas nécessaire*.

<a name='inserer_mot_declenchant_une_image'></a>
###Mot du texte de l'article déclenchant le son d'une image

@résumé rapide

    # à l'endroit où doit être placé l'image
    <%= image('path/to/image', center: true, no_control: true, mp3: 'rel/path/son') %>
    
    # dans le texte
    <%= link_play('rel/path/son', btn_jouer: "<texte>") %>

@détail

Utiliser le code suivant pour insérer la partition à l'endroit voulu&nbsp;:

    <%= image('path/to/image', center: true, no_control: true, mp3: 'rel/path/son') %>

*note&nbsp;: le `no_control:` permet de ne pas afficher le mot "Jouer", etc. à côté de l'image, car le controle se transformerait ensuite en le mot du texte.*

Dans le texte, insérer le grâce à&nbsp;:

    Le mot qui <%= link_play('rel/path/son', btn_jouer: "déclenche le son") %> dans
    le texte.

Noter que le `rel/path/son` doit être exactement le path fourni en attribut `:mp3` de la méthode `image` utilisé.

<a name='mot_du_texte_declenchant_son_sans_image'></a>
###Mot du texte déclenchant un son sans image

Insérer dans le texte en remplaçant `<texte>` par le mot ou le texte qui doit servir de déclenchement du son&nbsp;:

    <%= link_play('rel/path/son', btn_jouer: "<texte>", balise_audio: true) %>


<a name='fabriquer_la_partition'></a>
##Fabriquer la partition

Pour fabriquer la partition, utiliser de préférence RLily. Cf ce programme pour l'aide.

Mettre en entête de fichier, pour qu'un image simple sorte&nbsp;:

    SCORE::output_format  = :png
    SCORE::no_header      = true
    
*Note&nbsp;: Il est possible maintenant de faire une seule portée. Utiliser MD si on veut directement une clé de SOL ou MG si on veut une clé de FA (mais elles sont définissables aussi explicitement, cf. le manuel de RLilyl).*

<a name='fabrication_dune_image_sonore'></a>
##Fabrication d'un bout de partition sonore

Comment par [fabriquer la partition](#fabriquer_la_partition) et la placer dans le dossier `image/music` (en utilisant comme chemin relatif le même que l'article utilisant l'image, si elle doit être utilisée uniquement pour cet article).

Poursuivre en [créant le fichier son](#creer_le_fichier_son) associé à la partition.

<a name='creer_le_fichier_son'></a>
##Créer le fichier son


Ensuite, créer un fichier son, par exemple avec Reason, le créer dans le dossier&nbsp;:

    ./Musique/Piano/Cercle_pianistique/

* Ouvrir Reason
* Créer un nouveau fichier
* Créer un nouvel instrument
* Choisir le piano naturel
* Écrire les notes (ou les jouer)
* Exporter la portion voulue en fichier AIFF
* Utiliser le script AIFF_to_MP3 pour le transformer en MP3
* Télécharger avec Cyberduck le fichier MP3 dans le dossier `sound/cp/` sur mon hébergeur AlwaysData pour ICARE (Piano est trop petit pour le moment).
* Créer une balise dans l'article en ajoutant simplement `:mp3 => <affixe fichier mp3>` en second argument de méthode `image`. Tout le reste se fait tout seul.
  
Exemple de code&nbsp;:

    <%= image('path/to/image/partition02.png', center: true, mp3: 'path/to/partition02') %>

Pour définir le path, cf. [Bouton pour lancer le son](#partition_avec_bouton_pour_lancer_le_son).

<a name='gestion_dans_pstore_scores'></a>
##Gestion du pstore des scores

Les images de score, quelles qu'elles soient (fabriquées par l'admin ou l'user) sont consignés dans le pstore `scores.pstore`.

Chaque image fait l'objet de deux enregistrements&nbsp;:

    "<src>"   =>  <{data de l'image}>
    <id>      => "<src>"

On pourrait se passer de l'`<id>` mais c'est lui permet au reader de laisser des commentaires avec des partitions de façon simple (il indique simplement l'ID dans la balise `[score:<id>]`).
  
  
<a name='modify_traitement_note'></a>
##[PROGRAMME] Modification du traitement des notes

Ce n'est pas dans ce programme (Cercle pianistique) que sont traités les notes envoyées, mais sur Icare, dans le script-xextra 'rlily'. Exactement dans la méthode&nbsp;:

     rlily/Note/note_inst.rb#traite_notes