
* Ticket de désincription du follower
  -> Dans tous les mails qui lui sont envoyés, on ajoute un lien de désinscription renvoyant à ce ticket
    http://piano.alwaysdata.net/?t=<valeur ticket>&p=<code protection>
  > Que contient le ticket ?
      :protection   =>  le paramètre "p" qui permet de protéger le ticket
      :code         => le code à évaluer
                        p.e. "User::get_by_mail(<le mail>).unfollow_cercle"
    

* Fieldset synchro pour la table followers.pstore dans l'administration de la mailing list.

* last_connexion est enregistré pour un membre, il doit l'être pour un visiteur quelconque.

* Supprimer un membre de la mailing-list quand il était follower et qu'il
  est devenu membre.
  
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