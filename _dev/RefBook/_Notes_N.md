Dernier ID : N0002

N0001

  Pour empêcher qu'un pirate se fasse passer pour un membre en renseignant la variable session 'user_id', on enregistre l'ID de session courante dans les données même du membre lors de son identification (pas dans son pstore - session provisoire). La méthode User::retrieve_current peut donc contrôler que l'user_id en session correspond bien à une bonne session de membre.

  Dans le cas contraire, lorsqu'il n'y a pas piratage (lorsque la session a expiré par exemple), l'user est renvoyé vers le formulaire d'identification.

N0002

  La seule façon de reconnaitre un follower pour le moment, c'est lorsqu'il fournit son mail pour soumettre un commentaire.
  Dès qu'il le fait, on enregistre dans son pstore-session provisoire son mail (dans :follower_mail) et on définit son type (:user_type => :follower) qui permettront au prochain chargement de le reconnaitre.
  Si son IP n'est pas définie dans ses données, on en profite aussi pour prendre l'IP courante.