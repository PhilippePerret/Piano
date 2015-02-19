#Partitions

Un des plus (+) les plus importants du site est le recours dans les explications à des partitions pour la plupart sonores.

* [Fabriquer la partition](#fabriquer_la_partition)
* [Fabrication d'une partition sonore](#fabrication_dune_image_sonore)
* [Créer le fichier son](#creer_le_fichier_son)
* [Insertion dans la page ou le texte](#insertion_dans_la_page_ou_le_texte)
  * [Partition avec “bouton” pour lancer le son](#partition_avec_bouton_pour_lancer_le_son)
  * [Mot du texte de l'article déclenchant le son d'une image](#inserer_mot_declenchant_une_image)
  * [Mot du texte déclenchant un son sans image](#mot_du_texte_declenchant_son_sans_image)


<a name='insertion_dans_la_page_ou_le_texte'></a>
##Insertion dans la page ou le texte

<a name='partition_avec_bouton_pour_lancer_le_son'></a>
###Partition avec “bouton” pour lancer le son

    <%= image('path/to/image', center: true, mp3: 'path/to/son') %>

Ce code produit une image de la partition, avec le mot "Écouter" placé à côté pour lancer le son associé.

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
* Ouvrir le fichier AIFF dans iTune
* Choisir de faire un MP3 avec le menu contextuel
* Demander l'affichage dans le finder
* Déplacer le fichier de iTune vers le dossier principal de création du son

* Télécharger avec Cyberduck le fichier MP3 dans le dossier `sound/cp/` sur mon hébergeur AlwaysData pour ICARE (Piano est trop petit pour le moment).
* Créer une balise dans l'article en ajoutant simplement `:mp3 => <affixe fichier mp3>` en second argument de méthode `image`. Tout le reste se fait tout seul.
  
Exemple de code&nbsp;:

    <%= image('path/to/image/partition02.png', center: true, mp3: 'partition02') %>