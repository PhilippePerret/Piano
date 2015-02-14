* Mettre en forme le legend des fieldset

* Lorsqu'un article est marqué achevé, remettre sa propriété :votes (ou autre ?) à 0

* Formulaire pour voter pour un article
  - C'est un formulaire contenant l'ID de l'article courant
  - Il contient un radio groupe pour noter l'intérêt de l'article (de 1 à 10)
  - Il contient un radio groupe pour noter la clarté de l'article (de 1 à 10)
  
  On doit vérifier que l'user peut voter (comme can_vote_articles) mais :
  can_note_article( article_id )
  Ces données sont consignées dans un pstore contenant en clé l'IP de l'user, son numéro de session et son ID s'il est identifié.
  Les trois valeurs renvoient à un ID unique dans ce pstore.
  ID => Hash contenant la liste des ID et des notes attribuées par l'user.
  
  pstore
    "ip-IP"         => ID
    "user-IDuser"   => ID
    
    ID => {
      <article-id> => {:note_interet, :note_clarte, :time}
      <article-id> => {...idem...}
      etc.
    }
  end
  
* Formulaire pour laisser un commentaire sur l'article
  - test anti-robot
  - les enregistrer dans un pstore différent des data d'article
  
  
* Ajouter au mail la possibilité de se désinscrire de la liste de publication.


* Pouvoir utiliser l'option `:legend` avec la méthode `image` et produire une image avec une légende. L'utiliser pour l'article sur les altérations-double.

* Un bouton pour obtenir le lien direct à l'article.

* Nous avertir quand nouveau vote

* Supprimer un membre de la mailing-list quand il était follower et qu'il
  est devenu membre.
  
* Ajouter l'outil "Init all votes" pour la section administration des articles

* Tant que l'article n'est pas achevé (état 9), la propriété :votes permet de déterminer l'ordre de traitement. Quand il est achevé, on met :votes à 0 et la donnée servira pour attribuer une cote à l'article.

* Mettre en place le système de vote sur un article achevé. Gérer comme pour le vote des articles en projet, en interdisant plusieurs votes.

* Mettre en place une rubrique “Les âneries sur le piano” ou "sur la musique"
  - Visiter HP et relever toutes les bêtises racontées
  - Penser à mettre en garde contre les livres eux-même : cf. Fassina.
  
SUJETS À TRAITER
  * Commencer le piano à un âge tardif.
  * Ajout des difficultés des morceaux du moment dans les gammes et arpèges
    Exemple avec le morceau de Schubert en Ab (arpèges)
    Exemple avec le n°30 des CFP vol 1A (gammes en commençant sur do, puis mi, puis sol, puis do etc.)
  * Recueil d'âneries (cf. le fichier ./_dev/Recueil_aneries.md)