# encoding: UTF-8
=begin

Méthodes d'helper

Dans le vue ERB, on peut simplement les appeler par `<méthode name>`.

=end
class App
  
  LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse dignissim metus quam. Sed dignissim euismod leo. Mauris vitae arcu ullamcorper, malesuada velit a, sagittis dolor. Proin et arcu eget eros volutpat pellentesque a euismod turpis. Donec eu erat rhoncus, aliquet massa eu, aliquam elit. Aenean consectetur vel est at aliquet. Vestibulum eget nulla id odio malesuada posuere. Nulla eget interdum libero."

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
    
    # relpath_art = "main/home" if relpath_art.nil?
    
    for_mail        = options.delete(:mail)
    with_full_urls  = options.delete(:full_url) || use_full_urls || for_mail
    next_article    = options.delete(:next_article) || options.delete(:na)
    target          = options.delete(:target) || '_self'

    is_tdm      = relpath_art.end_with? '/'
    relpath_art = relpath_art[0..-2] if is_tdm
    prefix      = is_tdm ? 'tdm-' : ''
    article_tir = relpath_art.gsub(/\//, '-')
    
    ##
    ## Classe du lien
    ##
    class_css = ['alink']
    class_css << options.delete(:class) if options.has_key? :class
    class_css = class_css.join(' ')
    
    ##
    ## L'URL à utiliser (exacte ou relative)
    ##
    full_url = with_full_urls ? "#{App::FULL_URL}/" : ""
    
    ##
    ## Query-string
    ##
    ## Ce sont toutes les clés qui restent dans +options+
    ##
    qs = {}
    qs.merge!( na: next_article) unless next_article.nil?
    qs.merge!(options) unless options.empty?
    qs = qs.collect do |k, v| 
      "#{k}=#{CGI::escape v}" rescue nil # cas d'une variable oubliée
    end.reject{ |e| e.nil? }.join('&')
    qs = "?#{qs}" unless qs == ""
    
    
    href = "#{full_url}#{prefix}#{article_tir}#{qs}"
    
    return titre.in_a(href: href, target: target, class: class_css)
    
  end
  
  ##
  #
  # @return un lien (formulaire ou a) vers un article, en passant son
  # ID ou son idpath dans +pathorid+
  #
  def link_to_article pathorid, options = nil
    options ||= {}
    art = App::Article::get pathorid
    pathorid = art.idpath
    titre = options[:titre] || art.titre
    link_to titre, art.idpath, options
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
  # OU un path donné en valeur absolu
  #
  def link_offline_to_edit_article art = nil, titre = nil
    return "" if online?
    lk = link_textmate art, titre
    "<div class='right small'>#{lk}</div>"
  end
  
  def link_textmate art = nil, titre = nil
    art     ||= article
    fullpath = art.class == App::Article ? art.fullpath : art.to_s
    debug "fullpath: #{fullpath}"
    titre   ||= "[edit]"
    href  = "txmt://open/?url=file://#{fullpath}"
    "<a href='#{href}'>#{titre}</a>"
  end
  
end