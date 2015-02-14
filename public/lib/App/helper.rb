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
  #   form:           Si TRUE (par défaut), retourne un lien sous forme de 
  #                   formulaire (pour adresse "invisible")
  #   full_url:       Si TRUE utilise des URL complètes (pour mail par exemple)
  #   na:
  #   next_article:   Article suivant quand une opération est demandée
  #
  #   ----------
  #   Toutes les autres valeurs seront considérées comme des données à passer
  #   par l'url (si form: false) ou en champs hidden (formulaire)
  #
  # Voir aussi la méthode `link_to_article' qui permet de produire un
  # lien vers un article en fournissant seulement son ID ou son idpath
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
    
    with_full_urls  = options.delete(:full_url) || use_full_urls
    as_form         = options.delete(:form) == true
    next_article    = options.delete(:next_article) || options.delete(:na)
    
    # L'URL à utiliser
    full_url = with_full_urls ? App::FULL_URL : ""
    
    if as_form && use_links_a.nil?
      #
      # => Retourne un lien sous forme de formulaire
      #
      
      ##
      ## Champs hidden supplémentaires (if any)
      ##
      other_hiddens = options.collect { |k, v| v.in_hidden(name: k) }.join('')
      
      ##
      ## Construction du formulaire final
      ##
      "<form class='alink' action='index.rb' method='POST' onclick='this.submit()'>"+
        (next_article.nil? ? "" : next_article.in_hidden(name:'na')) +
        other_hiddens + 
        relpath_art.in_hidden(name: 'article') +
        titre.in_span +
        "</form>"
    else
      #
      # => Retourne un lien <a>
      #
      
      ##
      ## Query-string
      ##
      qs = {a: relpath_art}
      ## Article suivant (si opération)
      qs.merge!( na: next_article) unless next_article.nil?
      ## Autres données
      qs.merge!(options) unless options.empty?
      ## Construction finale
      qs = qs.collect{ |k, v| "#{k}=#{CGI::escape v}" }.join('&')
      
      ##
      ## Le lien retourné
      ##
      "<a href=\"#{full_url}?#{qs}\">#{titre}</a>"
    end
  end
  
  ##
  #
  # @return un lien (formulaire ou a) vers un article, en passant son
  # ID ou son idpath dans +pathorid+
  #
  def link_to_article pathorid, options = nil
    art = App::Article::get pathorid
    pathorid = art.idpath
    link_to art.titre, art.idpath, options
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