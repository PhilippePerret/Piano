  
* user_article_#can_note_article? retourne true pour le moment, car il merde en ONLINE (mais pas en offline)
  > Idem pour can_vote_articles?
  > Pouvoir réutiliser la méthode user_lecteur#save_session_id
  
*# Voir le problème avec les articles sans titre en ONLINE

* La méthode de classe User::get doit pouvoir retrouver n'importe quel lecteur, Membre (par ID ou Mail), Follower (par Mail) ou SimpleLecteur (par mail ou IP)

* Comme pour last_time, il faut enregistrer le time du fichier lors de son upload/download.
  Par exemple, un fichier chargé à 10:51 peut avoir un time de dernière modification à 7:21.
  Il faut donc :
    > Indiquer que le fichier a été uploadé à 10:51 et que sa date 
      de modification était 7:21. 
  De cette manière, on peut savoir si le fichier a été modifié online (ou offline)
  
* Ticket de désincription du follower
  -> à la création du follower, on enregistre un ticket dans ses données qui sera son ticket de désinscription.
  -> Dans tous les mails qui lui sont envoyés, on ajoute un lien de désinscription renvoyant à ce ticket
    http://piano.alwaysdata.net/?t=<valeur ticket>&p=<code protection>
  > Les tickets sont dans data/tickets
  > Que contient le ticket ?
      :protection   =>  le paramètre "p" qui permet de protéger le ticket
      :code         => le code à évaluer
                        p.e. "User::get_by_mail(<le mail>).unfollow_cercle"
    Quand le ticket est lu, le code est évalué
    
* Gérer le débug ONLINE pour pouvoir suivre le programme (enregistrer dans un fichier log temporaire).

* Fieldset synchro pour la table followers.pstore dans l'administration de la mailing list.

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

* Faire un article de désinscription comme follower. Utiliser le ticket créé.
  > L'user donne son mail
  > On regarde s'il existe (User::get_by_mail)
  > Dans ses données, on trouver :ti_unsub et :tp_unsub qui définissent le ticket de sa protection
  > On produit un lien dans la page avec ces deux données dans 'ti' et 'pt' dans l'url
  > L'user clique ce lien "Se désinscrire de la mailing-list". Le ticket est joué et l'user détruit.
  
SUJETS À TRAITER
  * Commencer le piano à un âge tardif.
  * Ajout des difficultés des morceaux du moment dans les gammes et arpèges
    Exemple avec le morceau de Schubert en Ab (arpèges)
    Exemple avec le n°30 des CFP vol 1A (gammes en commençant sur do, puis mi, puis sol, puis do etc.)
  * Recueil d'âneries (cf. le fichier ./_dev/Recueil_aneries.md)