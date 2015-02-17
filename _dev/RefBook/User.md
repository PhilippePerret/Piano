#User


* [User, Membre, Lecteur et Follower](#lecteur_user_and_follower)
* [Données de l'user](#data_user_lecteur)
* [ID de lecteur unique (:uid)](#identifiant_lecteur_unique)


<a name='lecteur_user_and_follower'></a>
##User, Membre, Lecteur et Follower

Il est important de ne pas confondre les quatre&nbsp;:

    USER
      C'est la classe générale qui concerne même un visiteur
      inconnu non trustable (qui n'a pas de REMOTE ADDR)
      
    MEMBRE
      Un membre est un utilisateur spécial, qui a été accepté au sein
      du cercle après un vote.
      Ses données sont enregistrées dans membres.pstore
    
    FOLLOWER
      Un follower est un visiteur trustable qui s'est inscrit sur la mailing
      list pour être informé des actualisations.
      Ses données sont enregistrées dans followers.pstore
      
    LECTEUR
      Un "lecteur" peut être soit un MEMBRE, soit un FOLLOWER, soit un simple
      USER trustable.
      Ils possèdent chacun un ID unique et absolu, appelé UID. Cet UID sert de
      clé dans la table lecteurs.pstore
      Noter que pour les membres, cet ID ne correspond pas à l'ID en tant que
      membre.
      On peut pointer vers cet UID (le retrouver) à l'aide de la table pstore
      pointeurs_lecteurs.pstore où toutes ces valeurs pointent (retourne) l'UID
      du lecteur :
        - REMOTE_ADDR (appelée `remote_ip' dans <user>)
        - mail
        - ID membre (si membre)
        - SESSION_ID (app.session.id)

<a name='data_user_lecteur'></a>
##Données de l'user

Les données de l'user quelconque se récupère par `data_reader`&nbsp;:

    data = <user>.data_reader

Pour un membre elles se récupèrent par `data`&nbsp;:

    data = <user membre>.data

Les données d'un membre contiennent les données qui sont vraiment propres au membre, comme son statut.


<a name='identifiant_lecteur_unique'></a>
##ID de lecteur unique (:uid)

L'ID de lecteur unique `uid` permet de définir un lecteur soit par son mail, soit par son IP soit par son identifiant de membre.

Seuls les lecteurs "trustable" (donc qui ont un REMOTE_ADDR) peuvent être enregistrés comme lecteur. Les autres n'ont aucune possibilité de noter, coter, etc. donc ne sont pas concernés.

Le pstore `pointeurs_lecteurs.pstore` permet de consigner les :uid. 

    <adresse IP>    => <uid>
    <id membre>     => <uid>
    <mail>          => <uid>

On peut se servir ensuite de cet `:uid` pour obtenir les informations de l'user dans le pstore `lecteurs.pstore`

    <uid>    =>   {
      type:             :membre | :follower | nil
      membre:           true si membre
      follower:         true si follower
      id:               <id membre> | <mail follower> | nil
      last_connexion:   {Fixnum} Timestamp de la dernière connexion
      articles_noted:   {Array} Liste des IDs des articles notés
      last_vote:        {Fixnum} Timestamp du dernier vote
    }