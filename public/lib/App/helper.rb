# encoding: UTF-8
=begin

Méthodes d'helper

Dans le vue ERB, on peut simplement les appeler par `<méthode name>`.

=end
class App
  
  ##
  #
  # Retourne un lien (<a>) vers l'article de path relatif +relpath_art+ dans
  # le dossiser `./public/page/article`.
  #
  # Si +titre+ est un symbole, c'est un raccouci qui définit le titre et
  # le chemin relatif. Cf. dans le fichier App/article.rb la constante 
  # App::Article::SHORTCUTS.
  #
  # +options+
  #   form:       Si TRUE (par défaut), retourne un lien sous forme de 
  #               formulaire (pour adresse "invisible")
  #
  attr_accessor :use_full_urls
  attr_accessor :use_links_a
  def link_to titre, relpath_art = nil, options = nil
    options ||= {}
    options.merge!(form: true) unless options.has_key?(:form)
    if titre.class == Symbol
      # => Un lien par raccourci
      dshortcut = App::Article::SHORTCUTS[titre]
      titre       = dshortcut[:titre]
      relpath_art = dshortcut[:relpath]
    elsif relpath_art.class == Symbol
      # => Un lien par raccourci avec titre donné
      dshortcut = App::Article::SHORTCUTS[relpath_art]
      relpath_art = dshortcut[:relpath]
    end
    
    ##
    ## Constantes qu'on peut utiliser dans certaines procédures
    ## pour forcer l'utilisation d'un format.
    ## Pour le moment, utilisé pour les mails pour pouvoir
    ## utiliser `link_to' sans options
    ##
    
    
    full_url = if options[:full_url] || use_full_urls
      App::FULL_URL
    else
      ""
    end
    
    if options[:form] && use_links_a.nil?
      #
      # => Retourne un lien sous forme de formulaire
      #
      "<form class='alink' action='index.rb' method='POST' onclick='this.submit()'>"+
        (options[:next_article] || "").in_hidden(name:'na') +
        relpath_art.in_hidden(name: 'article') +
        titre +
        "</form>"
    else
      #
      # => Retourne un lien <a>
      #
      relpath_art = CGI::escape relpath_art
      "<a href='#{full_url}?a=#{relpath_art}'>#{titre}</a>"
    end
  end
  
  ##
  #
  # Méthode d'helper retournant un lien pour rejoindre la table des matières
  # du dossier d'article courant
  #
  def link_to_tdm
    return "" if article.name == "_tdm_.erb"
    <<-HTML
<div class='link_to_tdm fright'>
  #{link_to 'Table des mati&egrave;res', "#{article.folder}/"}
</div>
    HTML
  end
  
  
  ##
  #
  # Retourne un lien textmate pour éditer l'article courant
  #
  #
  def link_offline_to_edit_article
    return "" if online?
    href  = "txmt://open/?url=file://#{article.fullpath}"
    lk    = "<a href='#{href}'>[edit]</a>"
    "<div class='right small'>#{lk}</div>"
  end
  
end