# encoding: UTF-8
=begin

Méthode d'instance gérant les articles

=end
class App
  
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
  # Méthode d'helper retournant un lien pour rejoindre la table des matières
  # du dossier d'article courant
  #
  def link_to_tdm
    return "" if article_name == "_tdm_.erb"
    <<-HTML
<div class='link_to_tdm'>
  #{link_to 'Table des mati&egrave;res', "#{folder_article}/"}
</div>
    HTML
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
      '<li>' + link_to( dtitre.first, path_to_article(dtitre.last) ) + '</li>'
    end.join("")
    c << "</ul>"
    return c
  end
  def path_to_article rp
    File.join(folder_article, rp)
  end
end