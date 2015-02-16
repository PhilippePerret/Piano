#Tickets

Les tickets permettent d'effectuer des actions depuis un mail, en un seul click. Elles ont été initiées pour la désinscription d'un follower.

* [Création d'un ticket](#creation_dun_ticket)
  * [Code pour la création d'un nouveau ticket](#code_pour_creation_ticket)
* [Traitement d'un ticket](#traitement_dun_ticket)

<a name='creation_dun_ticket'></a>
##Création d'un ticket

Usage dans le programme

    app.new_ticket_with_code <code>

Cette méthode exécute les opérations suivantes&nbsp;:

    ticket = App::Ticket::new
    ticket.create_with_code "<le code qui sera évalué>"
    # that's all folks

Cf. la suite pour le code à envoyer.

<a name='code_pour_creation_ticket'></a>
###Code pour la création d'un nouveau ticket

Le code à envoyer à la méthode `ticket.create_with_code` doit être une procédure en string&nbsp;:

    "Proc::new { <code à évaluer> }"

<a name='traitement_dun_ticket'></a>
##Traitement d'un ticket

Un ticket est automatiquement exécuté lorsqu'on trouve dans l'URL (ou plus rarement dans un formulaire) le paramètre `ti` (ID du ticket = nom du fichier) et `tp` la valeur de protection du ticket.


