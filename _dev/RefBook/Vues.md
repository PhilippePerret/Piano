#Les Vues

* [Chargement automatique des css, js et rb](#chargement_automatique_elements)
* [Vues pour des mails](#vues_de_mail)

Cette partie concerne les articles (qui sont des vues ERB) au niveau des fichiers.

<a name='chargement_automatique_elements'></a>
##Chargement automatique des css, js et rb

Quand une vue est demandée (un article, mais aussi une vue insérée dans un article), on fonctionne en "convention over configuration"&nbsp;:

###Quand dossier de même nom

Si un dossier de même nom que l'article (affixe) existe, tous ses éléments `css`, `*_mini.js` et `rb` sont chargés.

    ./public/page/article/.../mon_article.erb
    ./public/page/article/.../mon_article/
    
    # Quand la vue 'mon_article.erb' est chargé, tous les éléments du
    # dossier 'mon_article' sont chargés, les feuilles de style, les
    # script JS et les modules ruby.
    
###Quand fichier de même affixe

Il en va de même pour les fichiers qui portent le même affixe que la vue mais portent l'extions `.css` ou se terminent par `_mini.js` pour les javascripts.

Mais il vaut mieux utiliser un dossier de nom correspondant à l'affixe de la vue.

Note&nbsp;: Les modules ruby ne sont pas traités par ce biais, il faut obligatoirement les mettre dans un dossier au nom de l'affixe du fichier de la vue.

<a name='vues_de_mail'></a>
##Vues pour des mails

Cf. le fichier RefBook > Mails.md