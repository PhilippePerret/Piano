#Redirection

Code à utiliser pour créer une redirection&nbsp;:

    redirect_to '<path/article>'[, '<path/next/article>']

##Exemple

####Redirection simple vers un article par id-path

    redirect_to 'blog/tilleul/'
    raise RedirectError

La méthode renvoie vers la table des matières du blog de Tilleul.

*Note&nbsp;: `raise RedirectError` est à utiliser si cette redirection est appelée depuis une vue ERB.*

####Redirection simple vers un article par shortcut

    redirect_to :articles_en_projet
    raise RedirectError

*Note&nbsp;: `raise RedirectError` est à utiliser si cette redirection est appelée depuis une vue ERB.*

####Redirection vers la page d'identification

Dans une vue, pour empêcher l'affichage de la vue et rediriger vers une autre page. Ici, c'est le visiteur qui essaie d'atteindre une vue qui n'est accessible qu'en étant identifié. Le code renvoie au formulaire d'identification en mémorisant l'article qu'il faudra chargé si l'identification est correcte.

    unless cu.identified?
      redirect_to :login, app.article.idpath
      raise RedirectError
    end

####Explication détaillée du code

    ##
    ## Si le visiteur n'est pas identifié, la condition
    ## est remplie
    ##
    unless cu.identified?
    
      ##
      ## On redirige vers la page de login, en mémorisant l'article
      ## que voulait voir l'utilisateur (app.current_article -- = idpath)
      ##
      redirect_to :login, app.current_article
      
      ##
      ## On produit l'erreur propre qui fera que la vue ne génèrera pas
      ## d'erreur mais renverra simplement un string vide.
      ##
      raise RedirectError
      
      ##
      ## Fin de la condition
      ##
    end
