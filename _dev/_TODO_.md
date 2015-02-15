URGENT

  * Gérer le fait de ne pas pouvoir voter deux fois pour un article

  * Préparer les pstores pointeurs_lecteurs et lecteurs avec les membres
    pour les enregistrer online
    
  * Rationnaliser définitivement l'usage de UID
    - voir où est consigné :last_connexion
    
PLUS TARD

RÉFLEXION SUR L'UID

  Imaginons qu'un membre actuel se connecte
    -> il a une REMOTE_ADDR (remote_ip)
    -> il a une session     (app.session.id)
  Dans le pstore des pointeurs, il n'y a que son mail et son ID qui
  pointe vers son UID. Sa remote address n'est pas enregistrée puisqu'on ne
  l'a fait que manuellement.

  Il faudrait une méthode qui vérifie, une fois que l'user est reconnu comme
  membre (ou comme follower) que son pointeur remote_ip est bien défini.
  
  
  

* Pour l'UID : noter qu'un lecteur trustable est toujours enregistré dans la table des lecteurs (+pointeurs) avant de pouvoir devenir follower ou membre, etc. Il faut donc faire un check quelque part pour ne pas doubler les informations.
  -> à la création du follower
  -> à la création du membre
  
* Récupérer l'URL d'un article
  - l'envoyer à Isabelle Schieffer en lui répondant

* Fieldset synchro pour la table followers.pstore dans l'administration de la mailing list.

* Mettre en place la section administration pour valider les commentaires

* Améliorer le fieldset synchro
  - enregistrer vraiment la date d'upload en la fournissant explicitement
    à set_last_time (avec argument optionnel de la date à enregistrer)
  - indiquer quand le fichier a été modifié online depuis le dernier upload

* Section administration des articles : tester aussi la synchro du fichier de correspondance entre id et idpath
  
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