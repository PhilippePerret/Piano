#User


* [Données de l'user](#data_user_lecteur)
* [ID de lecteur unique (:uid)](#identifiant_lecteur_unique)

<a name='data_user_lecteur'></a>
##Données de l'user

Les données de l'user quelconque se récupère par `data_as_lecteur`&nbsp;:

    data = <user>.data_as_lecteur

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