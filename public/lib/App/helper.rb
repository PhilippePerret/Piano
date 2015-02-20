# encoding: UTF-8
=begin

Méthodes d'helper

Dans le vue ERB, on peut simplement les appeler par `<méthode name>`.

=end
class App
  
  ##
  #
  # Requiert un JS du dossier 'js/optional'
  #
  def require_optional_js arr_js
    arr_js = [arr_js] unless arr_js.class == Array
    arr_js.each do |js|
      p = path_optional js, :js
      add_js p if File.exist? p
    end
  end
  def require_optional_css arr_css
    arr_css = [arr_css] unless arr_css.class == Array
    arr_css.each do |css|
      p = path_optional css, :css
      add_js p if File.exist? p
    end
  end
  
  ##
  # Retourne le path du script optionnel +js+ qui peut être fourni :
  #   - explicitement "..._mini.js"
  #   - seulement avec l'affixe simple (sans '_mini')
  #   - en nom sans "_mini" (….js)
  #
  def path_optional js_or_css, type
    dos = nil
    if js_or_css.index('/')
      dos = File.basename(js_or_css)
      dos = nil if dos == "."
    end
    aff = File.basename(js_or_css, File.extname(js_or_css))
    if type == :js
      aff.concat("_mini") unless aff.end_with? "_mini"
    end
    arr = []
    arr << dos unless dos.nil?
    arr << "#{aff}.#{type}"
    p = File.join(app.send("folder_#{type}".to_sym), 'optional', *arr)
    unless File.exist? p
      chose = type == :js ? "Le script JS optionnel" : "La CSS optionnelle"
      error "#{chose} #{File.basename(p)} est introuvable."
      error "Cherché dans path : #{p}" if offline?
    end
    return p
  end
  
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
  #   class:          Soit la classe du lien <a> ou du formulaire
  #   full_url:       Si TRUE utilise des URL complètes (pour mail par exemple)
  #   na:
  #   next_article:   Article suivant quand une opération est demandée
  #   mail:           Si TRUE, alors on retourne un lien <a> au lieu d'un
  #                   formulaire et des url complète. Correspond donc à
  #                   form: true, full_url: true
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
    
    for_mail        = options.delete(:mail)
    with_full_urls  = options.delete(:full_url) || use_full_urls || for_mail
    as_form         = options.delete(:form) == true
    as_form = false if for_mail
    next_article    = options.delete(:next_article) || options.delete(:na)
    target          = options.delete(:target) || '_self'
    
    class_css = ['alink']
    class_css << options.delete(:class) if options.has_key? :class
    class_css = class_css.join(' ')
    
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
      "<form class='#{class_css}' target='#{target}' action='index.rb' method='POST' onclick='this.submit()'>"+
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
      "<a href=\"#{full_url}?#{qs}\" target='#{target}' class='#{class_css}'>#{titre}</a>"
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
  # ou l'article ({App::Article}) fourni en argument.
  #
  def link_offline_to_edit_article art = nil, titre = nil
    return "" if online?
    lk = link_textmate art, titre
    "<div class='right small'>#{lk}</div>"
  end
  
  def link_textmate art = nil, titre = nil
    art     ||= article
    titre   ||= "[edit]"
    href  = "txmt://open/?url=file://#{art.fullpath}"
    "<a href='#{href}'>#{titre}</a>"
  end
  
end