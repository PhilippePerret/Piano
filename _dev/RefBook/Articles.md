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

Pour le détail de ce qui est chargé, cf. le fichier Vues.md.

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


* [Cotes de l'article](#cotes_de_larticle)
<a name='cotes_de_larticle'></a>
##Cotes de l'article

Les cotes d'un article, définies par les lecteurs, sont définis dans le pstore&nbsp;:

    ./data/pstore/articles_cotes.pstore

En clé principale est utilisé l'ID de l'article.

En valeur est retourné un `Hash` qui définit&nbsp;:

    {
      cote_finale:    <Hash données de la cote finale>,
      cotes:          <Array liste des cotes attribuées>,
      updated_at:     <Timestamp de dernière modification>
    }

`cote_finale` contient&nbsp;:

    cote_finale = {
      interet:          {Float} La note sur 4 attribuée pour l'intérêt de l'article
      clarity:          {Float} La note sur 4 attribuée pour la clareté de l'article
      note_interet:     {Fixnum} La note totale (non divisée), somme des notes d'intérêt
      note_clarity:     {Fixnum} La note totale, somme des notes de clareté
      nombre_votes:     {Fixnum} Le nombre total de votes pour cet article
    }

**`cotes`** est un `Array` qui contient des `Hash`. Chaque `Hash` représente une cote attribuée par un lecteur. On les enregistre juste pour mémoire.

    # Un élément du Array `cotes` contient :
    {
      i:      {Fixnum} La note d'intérêt de 0 à 4 attribuée par l'user
      c:      {Fixnum} La note de clareté de 0 à 4 attribuée par l'user
      n:      {Fixnum} Le niveau en théorie de l'user, de 0 à 4
      at:     {Fixnum} Timestamp de la date de la cote
      u:      {Fixnum} UID absolu de l'user (retourné par <user>.uid)
    }