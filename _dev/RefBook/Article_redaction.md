#Rédaction des articles


* [Insérer des images](#inserer_images)
* [Insérer une ancre](#inserer_balise_aname)
* [Insérer un lien vers une ancre](#link_to_ancre)


* [Insérer un article dans l'article courant](#inserer_article_in_article)
<a name='inserer_article_in_article'></a>
##Insérer un article dans l'article courant

@syntaxe

    <%= include_article "<path/to/article>" %>
    
`<path/to/article>` est le chemin relatif depuis `./public/page/article`.

<a name='inserer_images'></a>
##Insérer des images

Pour insérer des images dans le texte, utiliser la syntaxe suivante&nbsp;:

@synthaxe

    <%= image(<path relative>[, {<options>}]) %>

Le `path_relatif` est défini depuis le dossier des images `./public/page/img/`.

Les `options` sont un hash qui peut contenir&nbsp;:

    legend:     La légende de l'image
    center:     Mettre à true pour insérer l'image dans un div centré. L'image
                sera alors placée sur une ligne, centrée dans la page.
    float:      'left' ou 'right'. L'image sera placée dans un div flottant à
                gauche ou à droite.
                

<a name='inserer_balise_aname'></a>
##Insérer une ancre

@syntaxe

    <%= ancre "<name de la balise>" %>

@produit

    <a name="name de la balise"></a>

On peut alors simplement créer un lien (dans le même fichier) à cette balise en utilisant&nbsp;:

    <%= link_ancre "<titre lien>", "name de la balise" %>
    

<a name='link_to_ancre'></a>
##Insérer un lien vers une ancre

@syntaxe

    <%= link_ancre "<titre>", "<ancre name>"[, "<path/article>"]
    

Utiliser `<path/article>` si l'ancre se trouve dans un autre article que l'article dans lequel est inséré ce code.