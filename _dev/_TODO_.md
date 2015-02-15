* Fieldset synchro pour la table followers.pstore dans l'administration de la mailing list.

* Mettre en place la section administration pour valider les commentaires

* Améliorer le fieldset synchro
  - enregistrer vraiment la date d'upload en la fournissant explicitement
    à set_last_time (avec argument optionnel de la date à enregistrer)
  - indiquer quand le fichier a été modifié online depuis le dernier upload

* Section administration des articles : tester aussi la synchro du fichier de correspondance entre id et idpath
  
* Ajouter au mail la possibilité de se désinscrire de la liste de publication.

* last_connexion est enregistré pour un membre, il doit l'être pour un visiteur quelconque.

* Avertir quand nouveau vote

* Supprimer un membre de la mailing-list quand il était follower et qu'il
  est devenu membre.
  
* Ajouter l'outil "Init all votes" pour la section administration des articles

* Tant que l'article n'est pas achevé (état 9), la propriété :votes permet de déterminer l'ordre de traitement. Quand il est achevé, on met :votes à 0 et la donnée servira pour attribuer une cote à l'article.

* Mettre en place une rubrique “Les âneries sur le piano” ou "sur la musique"
  - Visiter HP et relever toutes les bêtises racontées
  - Penser à mettre en garde contre les livres eux-même : cf. Fassina.
  
SUJETS À TRAITER
  * Commencer le piano à un âge tardif.
  * Ajout des difficultés des morceaux du moment dans les gammes et arpèges
    Exemple avec le morceau de Schubert en Ab (arpèges)
    Exemple avec le n°30 des CFP vol 1A (gammes en commençant sur do, puis mi, puis sol, puis do etc.)
  * Recueil d'âneries (cf. le fichier ./_dev/Recueil_aneries.md)