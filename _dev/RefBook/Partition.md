#Partitions

Un des plus (+) les plus importants du site est le recours dans les explications à des partitions pour la plupart sonores.

* [Fabriquer la partition](#fabriquer_la_partition)
* [Fabrication d'une partition sonore](#fabrication_dune_image_sonore)


<a name='fabriquer_la_partition'></a>
##Fabriquer la partition

Pour fabriquer la partition, utiliser de préférence RLily. Cf ce programme pour l'aide.

<a name='fabrication_dune_image_sonore'></a>
##Fabrication d'un bout de partition sonore

Comment par [fabriquer la partition](#fabriquer_la_partition).

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