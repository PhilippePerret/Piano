* [cron] Tenir compte du fait qu'un même user peut se connecter plusieurs
  fois dans la journée, avec expiration des sessions => plusieurs sessions
  donc plusieurs fichiers pour le même user.

[TRAITEMENT DU PSTORE PROVISOIRE]
  :deconnexion    
    Cette donnée est définie si c'était un membre identifié, et qu'il s'est déconnecté.
  :articles
    Contient toutes les données des articles lus au cours de cette
    session. C'est un Hash avec en clé l'ID de l'article et en 
    valeur :
      {
        id:       ID article,
        start:    Début de première lecture au cours de la session
        end:      Fin de la dernière lecture au cours de la session
        duree:    La durée totale de lecture
        discontinous:   Mis à TRUE si l'article a été plusieurs fois atteint
                        au cours de la session.
      }


* Dès que l'user est reconnu comme follower (soumission d'un commentaire), on store son `:follower_mail`

    <user>.store :follower_mail => umail
  
  Cela permettra au cron de retrouver l'user s'il s'est connecté d'un autre ordinateur.