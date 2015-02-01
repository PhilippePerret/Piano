#Gestion des articles

* [Aperçu général](#apercu_general)
* [Lien vers un article](#lien_vers_un_article)

<a name='apercu_general'></a>
##Aperçu général

Tous les articles sont rassemblés dans le dossier&nbsp;:

    ./public/page/article/

Le fonctionnement de base est le suivant&nbsp;: Ça n'est pas l'article qui est chargé directement, mais le fichier `_body_.erb` à la racine de son dossier principal.

Exemple pour l'article de path relatif `theme/ni_pour_ni_contre/acoustique_numerique.erb`&nbsp;:


<a name='lien_vers_un_article'></a>
##Lien vers un article

    <%= link_to "<titre article>", "<path/to/article>" %>

La méthode `link_to` retournera un formulaire pour afficher l'article de path relatif `path/to/article`.

Le path relatif est considéré depuis `./public/page/article/`.

* [Créer un nouveau dossier article](#creer_nouveau_dossier_article)
<a name='creer_nouveau_dossier_article'></a>
##Créer un nouveau dossier article

* Créer le dossier dans `./public/page/article/`
* Créer le fichier `_body_.erb` dans ce dossier avec le code minimum suivant&nbsp;:

      <h1>TITRE DE CE DOSSIER</h1>
      <%= link_to_tdm %>
      <%= article_view %>
      <%= link_to_tdm %>
* Créer le fichier `_tdm_.erb` qui va contenir la table des matières du dossier d'articles. Dans ce fichier, il suffit de coller&nbsp;:

    <%=
      tdm_dossier_article([
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