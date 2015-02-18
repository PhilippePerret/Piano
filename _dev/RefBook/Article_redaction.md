#Rédaction des articles


* [Insérer un article dans l'article courant](#inserer_article_in_article)
* [Insérer des images](#inserer_images)
* [Insérer une ancre](#inserer_balise_aname)
* [Insérer un lien vers une ancre](#link_to_ancre)
* [Bouton pour lancer une opération (non "o")](#bouton_to_run_operation)
* [Lien vers la page suivante](#lien_to_page_suivante)



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

<a name='lien_to_page_suivante'></a>
##Lien vers la page suivante

Pour ajouter un lien qui pointe vers la page suivante, insérer quelque part dans le code de la vue ERB&nbsp;:

    <% article.next = "path/to/article" %>
    
Cela insèrera le bouton "Suivant ->" à côté des boutons de bas de page.


<a name='bouton_to_run_operation'></a>
##Bouton pour lancer une opération (non "o")

*Note&nbsp;: Pour une opération “o”, utiliser la méthode `form_o`.*

Pour lancer une opération qui sera exécuter dans l'article et reviendra donc sur l'article, utiliser la méthode&nbsp;:

    button_operation "<nom bouton>", "<operation>"[, options]
    # alias : bouton_operation

Par exemple&nbsp;:

    <%= button_operation "Montrer la liste", 'show_list' %>

*Note&nbsp;: Cf. ci-dessous pour les `options` possibles.*

Dans la page/l'article, il faut trouver alors un code&nbsp;:

    <%
      if param(:operation).to_s != ""
        <ClassTruc::SousClassTruc>::send(param(:operation).to_sym)
      end
    %>

Cette opération peut être définie dans un module qui se trouve dans un dossier de même nom que l'affixe du fichier, qui est automatiquement chargé.

La méthode retourne un formulaire (`FORM`).

####Aspect

Par défaut, le formulaire apparait comme un bouton simple, orange entouré d'un cadre (grâce aux classes css `alink` et `btn` appliquées au formulaire).

####Options

Par défaut, c'est l'article courant qui est utilisé. Mais on peut définir un autre article à l'aide de&nbsp;:

    options[:article] = {Instance App::Article}

Autres options pour le troisième argument&nbsp;:

    btn_class:        {String} Classes CSS pour le bouton submit
    form_id:          {String} Identifiant du formulaire
    form_class:       {String} Classes CSS du formulaire
    