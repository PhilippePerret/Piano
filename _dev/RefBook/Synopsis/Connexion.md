#Synopsis des connections

Ce fichier essaie de considérer tous les cas possibles, pour pouvoir établir des tests solides.

* [Toute première connexion d'un visiteur inconnu](#premiere_connexion_user_tout_a_fait_inconnu)
* [Première connexion d'un user connu](#premiere_connexion_dun_user_connu)
* [Cas particulier de deux lecteurs se connectant sur le même ordinateur](#exemple_particulier_deux_users_meme_remote_ip)

<a name='premiere_connexion_user_tout_a_fait_inconnu'></a>
##Toute première connexion d'un visiteur inconnu

Première connexion signifie que&nbsp;:

* Le **session-id** est inconnu

Un visiteur inconnu signifie que&nbsp;:

* Son adresse distante (REMOTE_ADDR) est inconnue.

###Synopsis général

    - Le visiteur arrive sur le site
    - Son UID étant introuvable, on crée un nouveau Reader
      dans la table readers.pstore

<a name='premiere_connexion_dun_user_connu'></a>
##Première connexion d'un user connu

Première connexion signifie que&nbsp;:

* Le **session-id** est inconnu, tout à fait unique.

Un `user connu` signifie que&nbsp;:

* Sa REMOTE-ADDR est connu dans les pointeurs
* Il a un enregistrement reader dans readers.pstore
* Il possède des pointeurs par son REMOTE-ADDR

###Synopsis général

    - Le visiteur arrive sur le site
    - Son UID est trouvable par sa REMOTE-ADDR
    - Par ses données, on peut déjà savoir si c'est un membre,
      un follower ou un simple lecteur.
    

* [Connexion d'un membre depuis un autre ordinateur inconnu](#connexion_membre_sur_autre_ordinateur)
<a name='connexion_membre_sur_autre_ordinateur'></a>
##Connexion d'un membre depuis un autre ordinateur inconnu


* [Connexion d'un membre depuis un autre ordinateur connu](#connexion_membre_depuis_ordinateur_autre_reader)
<a name='connexion_membre_depuis_ordinateur_autre_reader'></a>
##Connexion d'un membre depuis un autre ordinateur connu

“Ordinateur connu” signifie que&nbsp;:

* la remote-addr est connu du site
* Cette remote-addr n'est pas associé au membre, mais à un autre reader que lui

###Synopsis

    - Le membre arrive sur le site
    - La REMOTE-ADDR est reconnue, envoyant l'UID de l'autre reader
      Donc, c'est comme si c'était l'autre reader qui arrivait sur le site
    - Le membre s'identifie
      Le site ne comprend plus :-)
        Mais il doit pouvoir comprendre : l'UID correspond à un reader qui
        n'a rien à voir avec lui, il doit en déduire ce qui se passe.
      Le site NE DOIT PAS MODIFIER LES POINTEURS, ce qui associerait l'autre
      reader au membre.
      EN FAIT, LE PROBLÈME EST RÉGLÉ MAINTENANT AVEC L'UTILISATION D'UN PSTORE
      UNIQUE POUR LA SESSION : Une fois que l'user est identifié, le pstore est
      associé au membre, et plus aucune trace de sa connexion depuis un autre
      ordinateur.
      

<a name='exemple_particulier_deux_users_meme_remote_ip'></a>
##Cas particulier de deux lecteurs se connectant sur le même ordinateur

Cette section étudie le cas où deux lecteurs (qui peuvent être par exemple membre ou follower) se déconnectent depuis le même ordinateur donc possède la même REMOTE-ADDR.

