#Gestion des articles

* [Aperçu général](#apercu_general)
* [Fonctionnement du chargement des articles (synopsis)](#fonctionnement_chargement_article)
* [Lien vers un article](#lien_vers_un_article)
* [Créer un nouveau dossier article](#creer_nouveau_dossier_article)
* [Méthodes “raccourcis” pour les vues](#methode_raccourcis)



<a name='apercu_general'></a>
##Aperçu général

Tous les articles sont rassemblés dans le dossier&nbsp;:

    ./public/page/article/

Le fonctionnement de base est le suivant&nbsp;: Ça n'est pas l'article qui est chargé directement, mais le fichier `_body_.erb` à la racine de son dossier principal.

Exemple pour l'article de path relatif `theme/ni_pour_ni_contre/acoustique_numerique.erb`&nbsp;:

<a name='fonctionnement_chargement_article'></a>
##Fonctionnement du chargement des articles (synopsis)

Un article est défini par le paramètre `:article` qu'on récupère par `param :article`.

    > Exemple avec l'article "theme/contre/lire_en_jouant.erb"
      = article = "theme/contre/lire_en_jouant"
      
    [1] * L'application cherche le dossier de l'article
          EX: "theme/contre/"
    
    [2] * Elle charge le fichier `_body_.erb` de ce dossier
        EX: "theme/contre/_body_.erb"
    
    [3] * La vue `_body_.erb` charge l'article défini
        EX: `lire_en_jouant.erb`

Pour la table des matières, on définit l'article sans renseigner le nom de l'article, mais en laissant bien le `/` à la fin du path.

    EX: article = "theme/contre/"

Dans l'étape de chargement ([3]) le programme cherche alors la vue `_tdm_.erb` qui se trouve dans le dossier des articles.

<a name='lien_vers_un_article'></a>
##Lien vers un article

    <%= link_to "<titre article>", "<path/to/article>" %>

La méthode `link_to` retournera un formulaire pour afficher l'article de path relatif `path/to/article`.

Le path relatif est considéré depuis le dossier `./public/page/article/`.

###Raccourcis

On peut aussi utiliser des raccourcis avec `link_to`. Par exemple&nbsp;:

    <%= link_to :home %>

Ces raccourcis sont définis dans le fichier `./public/lib/App/article.rb`, dans la constante `App::Article::SHORTCUTS`.

Mettre les options en troisième paramètre.

  :form       Si FALSE retourne un lien au lieu d'un formulaire
  :full_url   Si TRUE, l'url complète.

<a name='creer_nouveau_dossier_article'></a>
##Créer un nouveau dossier article

* Créer le dossier dans `./public/page/article/`
* Créer le fichier `_body_.erb` dans ce dossier avec le code minimum suivant&nbsp;:

      <h1>TITRE DE CE DOSSIER</h1>
      <%= link_to_tdm %>
      <%= article.view %>
      <%= link_to_tdm %>
* Créer le fichier `_tdm_.erb` qui va contenir la table des matières du dossier d'articles. Dans ce fichier, il suffit de coller&nbsp;:

    <%=
      App::Article::tdm_with([
        ["<titre 1>", "<path/to/article>"],
        ["<titre 2>", "<path/to/article>"],
        etc.
      ])
    %>
* Ajouter le lien vers ce dossier dans `rmargin_main_btns.erb` avec les données&nbsp;:
  
      ["<titre du dossier", "theme/<nom dossier>/"]
      # Ne pas oublier le "/" à la fin du path
      # noter que `theme` peut être remplacé par autre chose si le dossier ne
      # se trouve pas dans ./public/page/article/theme/
      
<a name='methode_raccourcis'></a>
##Méthodes “raccourcis” pour les vues

cf. le fichier "Article_redaction.md"