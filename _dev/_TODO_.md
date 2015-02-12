* Détection automatique du ERB dans mail et alerte si as_erb est faux (mailing)
 # GROS BUG : L'ID dans le pstore mailing list des users n'est pas le
   même que celui dans membres.pstore.
* Pouvoir évaluer le code du mail comme une vue ERB
* Nous avertir quand nouveau vote
* Avertir Serge
* Obtenir le titre de l'article tout de suite
* Pour le pstore des membres, maintenant, il faut le récupérer online, mais 
  attention quand même à ne pas faire de bêtises.
  Il faut aussi ramener en même temps 'mail_to_id.pstore'

* Supprimer un membre de la mailing-list quand il était follower et qu'il
  est devenu membre.
  
* Ajouter l'outil "Init all votes" pour la section administration des articles
* Tant que l'article n'est pas achevé (état 9), la propriété :votes permet de déterminer l'ordre de traitement. Quand il est achevé, on met :votes à 0 et la donnée servira pour attribuer une cote à l'article.

* Mettre en place une rubrique “Les âneries sur le piano” ou "sur la musique"
  - Visiter HP et relever toutes les bêtises racontées
  - Penser à mettre en garde contre les livres eux-même : cf. Fassina.
  
SUJETS À TRAITER
  * La pédale (ni pour ni contre)
  * [Pratique] Tirer des exercices de ses morceaux [installé en draft]
  * [Théorie] Différence entre exercice, étude et Morceau
  * Commencer le piano à un âge tardif.
  * Ajout des difficultés des morceaux du moment dans les gammes et arpèges
    Exemple avec le morceau de Schubert en Ab (arpèges)
    Exemple avec le n°30 des CFP vol 1A (gammes en commençant sur do, puis mi, puis sol, puis do etc.)
  * Recueil d'âneries (cf. le fichier ./_dev/Recueil_aneries.md)
  * Mystère des doubles-dièses et double-bémol (exemple avec un morceau qui passe de Ré#mineur à Ré#majeur — en donnant d'abord l'exemple avec Rémineur qui passe en Ré majeur). On pourrait avoir aussi dans cet article la raison de la tonalité de Lab mineur pour le morceau de Schubert