# encoding: UTF-8
=begin

Méthode d'instance gérant les articles

=end
class App
  
  ##
  ## Raccourcis à utiliser avec la méthode d'helper `link_to'. Par exemple :
  ## <%= link_to :home %>
  ##
  SHORTCUTS = {
    :home       => {titre: "Accueil", relpath: 'main/home'},
    :mailing    => {titre: "s'inscrire sur le mailing-list", relpath: 'main/rester_informed'}
  }
  
  ##
  #
  # Méthode principal, appelée par la vue `content.erb', qui retourne
  # le code de l'article.
  #
  # @return le code HTML complet de l'article
  #
  def load_article
    view "article/#{article_base}"
  end
  
  ##
  #
  # @return le path relatif du fichier ERB principal à afficher dans le
  # dossier ./public/page/article/
  #
  def article_base
    if folder_article == "main"
      "#{relpath_article}"
    else
      "#{folder_article}/_body_.erb"
    end
  end
  
  ##
  #
  # Méthode appelée par les fichier `_body_.erb' des dossiers d'article
  # retournant le code de l'article précisément demandé.
  #
  def article_view
    view "article/#{folder_article}/#{article_name}"
  end
  
  
  ##
  #
  # Retourne le chemin complet à l'article demandé
  # Utilisé seulement pour l'édition de l'article (dans les autres cas,
  # c'est le fichier _body_.erb qui est chargé et qui charge l'article)
  #
  def article_full_path
    @article_full_path ||= File.expand_path(File.join('.','public','page','article',folder_article, article_name))
  end
  
  ##
  #
  # @return le dossier (nom) de l'article courant
  #
  def folder_article
    @folder_article ||= File.dirname(relpath_article)
  end
  
  ##
  #
  # @return le chemin relatif à l'article à afficher
  # 
  # Il doit être contenu dans le paramètre "article". S'il est non
  # défini, c'est "main/home"
  #
  # Tous les articles se trouvent dans le dossier ./public/page/article/
  #
  def relpath_article
    @relpath_article ||= begin
      rp = cgi["article"]
      rp = "main/home" if rp.to_s == ""
      rp.concat('.erb') unless rp.end_with? '.erb'
      rp
    end
  end
  
  def article_name
    @article_name ||= begin
      artname = File.basename(relpath_article)
      artname = "_tdm_.erb" if artname.to_s == ".erb"
      artname
    end
  end
  
  ##
  #
  # @return le code HTML pour une table des matières d'un dossier
  # d'article.
  #
  # C'est le code à insérer dans le fichier _tdm_.erb
  #
  def tdm_dossier_article arr_titres
    c = "<ul class='tdm'>"
    c << arr_titres.collect do |dtitre|
      titre, artname, a_venir = dtitre
      '<li>' + link_to( titre, path_to_article(artname) ) + (a_venir ? img_a_venir : '') + '</li>'
    end.join("")
    c << "</ul>"
    return c
  end
  def path_to_article rp
    File.join(folder_article, rp)
  end
  def img_a_venir
    @img_a_venir ||= "<img class='avenir' src='./public/page/img/a_venir.png' />"
  end
end