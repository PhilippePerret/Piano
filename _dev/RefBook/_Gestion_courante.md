#Gestion courante du site

* [Quand un article est terminé](#new_article_complete)

<a name='new_article_complete'></a>
##Quand un article est terminé

Opérations à faire lorsqu'un article est achevé&nbsp;:

Tout est fait en OFFLINE.

* Vérifier que la table des matières du dossier de l'article ne contienne plus le `true` pour cet article, indiquant qu'il est en projet&nbsp;;
  * Uploader cette TdM le cas échéant&nbsp;;
* Rejoindre l'administration des articles OFFLINE
  * Rappatrier le pstore articles.pstore online
  * Relever l'ID dans l'administration des articles&nbsp;;
  * Marquer l'article achevé
  * Uploader les données des articles
* Rejoindre la section administration Mailing-list
  * Faire une annonce aux followers grâce au formulaire préformaté&nbsp;;
* Ajouter l'article à la LISTE DES DERNIERS ARTICLES dans le fichier :
    `./public/_hot_data_/last_articles.rb`

Note&nbsp;: L'upload sur le site de l'article sera faite automatiquement lors de l'envoi de l'annonce de publication.