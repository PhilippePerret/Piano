* Dans check_as_membre (après login), il faut vérifier que l'user a bien sa propriété :uid définie et la définir au cas où.
  Vérifier la concordance des uid. 
    - uid n'est pas défini pour le membre => l'enregistrer
    - uid ne correspondent pas => le membre se connecte d'un ordinateur
      connu
    - uid correspondent => tout va bien

* [cron] Tenir compte du fait qu'un même user peut se connecter plusieurs
  fois dans la journée, avec expiration des sessions => plusieurs sessions
  donc plusieurs fichiers pour le même user.

[TRAITEMENT DU PSTORE PROVISOIRE]
  :deconnexion    
    Cette donnée est définie si c'était un membre identifié, et qu'il s'est déconnecté.

* Mettre en place le fait qu'on crée un pstore propre à l'user (de nom session-id), dans lequel on enregistre tout.
  Ensuite, au cours de la nuit, on remet ces données dans les pstores généraux.

* Même sans que je m'identifie, le site (local) me reconnait
  > Il ne faut pas. Il faut me laisser en reader.
  > Voir si c'est toujours le cas depuis que logout détruit plus de choses

* Dès que l'user est reconnu comme follower (soumission d'un commentaire), on store son `:follower_mail`

    <user>.store :follower_mail => umail
  
  Cela permettra au cron de retrouver l'user s'il s'est connecté d'un autre ordinateur.