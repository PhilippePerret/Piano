#Rédaction des articles


* [Insérer un autre article dans l'article courant](#inserer_article_in_article)
* [Insérer des images](#inserer_images)
  * [Afficher une portion de l'image](#afficher_une_portion_seulement_de_limage)
* [Insérer une ancre](#inserer_balise_aname)
* [Bouton pour lancer une opération (NON "o")](#bouton_to_run_operation)
* **Types de liens**
  * [Insérer un lien vers une ancre](#link_to_ancre)
  * [Lien vers la page suivante](#lien_to_page_suivante)
  * [Lien vers un autre article](#lien_vers_un_autre_article)
  * [Lien vers l'aide](#lien_vers_aide)


<a name='lien_vers_un_autre_article'></a>
##Lien vers un autre article

    link_to_article <id | idpath>[, <{options>}]


<a name='lien_vers_aide'></a>
##Lien vers l'aide

    link_aide "<titre>", <id | idpath>[, <{options}>]

    alias : lien_aide

`id` correspond à l'identifiant de l'article (puisque les articles d'aide sont des articles comme les autres).

Les `<{options}>` sont les mêmes que pour la méthode générale `link_to`.

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

Le `path_relatif` est défini depuis le dossier des images `./public/page/img/` (ou depuis `/img/cp_score` sur l'atelier Icare si `:icare` est true dans les options).

Noter qu'on peut aussi utiliser pour une image sur Icare&nbsp;:

    <%= image_icare( <path/rel/to/image.png>[, <{options}>] ) %>

Les `options` sont un hash qui peut contenir&nbsp;:

    legend:     La légende de l'image
    center:     Mettre à true pour insérer l'image dans un div centré. L'image
                sera alors placée sur une ligne, centrée dans la page.
    float:      'left' ou 'right'. L'image sera placée dans un div flottant à
                gauche ou à droite.
    openable:   Si TRUE (FALSE par défaut), l'image est assez grande, elle est
                réduite pour être affichée mais quand on clique dessus elle
                s'affiche en entier.
                Un texte "cliquez sur l'image pour l'aggrandir" est placé au-dessus
                de l'image.
    icare:      Si TRUE (false par défaut) l'image est chargée depuis l'atelier
                Icare à partir du dossier img/cp_score/
    
    = Pour positionner seulement une partie de l'image =
    
    size:       Taille que doit avoir l'image cf. plus bas pour le détail
    offset:     Décalage dans l'image cf. plus bas pour le détail
    positionning:   Variable de travail. Si elle est mise à TRUE en offline, l'image
                    entière est affichée et un cadre entoure ce qui sera vu.
                    On peut alors jouer sur les propriétés left/top de l'image pour
                    saisir la portion voulue. Cf. ci-dessous.

<a name='afficher_une_portion_seulement_de_limage'></a>
###Afficher une portion de l'image

On se sert de la méthode d'helper `image` ou `image_icare` (cf. ci-dessus).

En options dans le deuxième argument envoyé à `image`, on se sert des propriétés&nbsp;:

    offset:   {Array} [décalage top, décalage left]
              Noter que ce sont des valeurs positives pour obtenir des valeurs
              négative :   si top = 90, le top de l'attribut style sera -90px.
    
    size:     {Array} [width, height] Taille finale de l'image, telle qu'affichée
              dans la page. Noter que ça n'aggrandira pas ni ne diminuera la taille
              réelle de l'image, ça définit simplement la taille de la portion
              d'image à voir.
    
    positionning  {Bool} Permet en OFFLINE de régler la position, c'est-à-dire de
              trouver les valeurs d':offset ci-dessus.
              Quand true, la page affiche toute l'image et un cadre indiquant quelle
              portion sera affichée.
              Il suffit alors de jouer sur le left et le top de l'image pour choisir
              la portion à voir (celle qui sera dans le cadre).
              Noter que les valeurs seront négatives mais qu'il faut fournir à la
              propriété :offset les mêmes valeurs positives.

Exemple&nbsp;:

    <%= image("mon/image.png", {offset: [200, 100], size: [300,50], positionning:true}) %>

Ce code écrira l'image en prenant une portion qui fera 300px de large sur 50px de haut, décalé de 200px du haut et de 100px de la gauche. Puisque :positionning est true, toute l'image sera visible et un cadre entourera la portion qui sera réellement affichée.

Cela signifie que la portion visible de l'image sera la suivante&nbsp;:

    200/100                      200/400
      ******************************
      *                            *
      *                            *
      ******************************
    250/100                      250/400

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
    