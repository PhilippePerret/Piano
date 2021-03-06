# encoding: UTF-8

class App
  
  ##
  #
  # Méthode de vue permettant d'insérer un article dans l'article
  # courant.
  #
  # Noter que cet article est placé dans un div.included afin d'adapter
  # les styles des titres.
  #
  def include_article path_article, options = nil
    options ||= {}
    display_article = options.delete(:display) != false
    unless display_article
      options.merge!(style: 'display:none;')
    end
    view(File.join('article', path_article)).in_div(class: 'included', id: options[:id], style: options[:style])
  end
  
  ##
  #
  # Pour insérer un bouton lançant une opération
  # cf. RefBook > Article_redaction.md
  #
  # Alias: def bouton_operation
  def button_operation button_name, operation, options = nil
    options ||= {}
    art = options.delete(:article) || article
    btn_class = ['btn_ope']
    btn_class << options[:btn_class] if options.has_key? :btn_class
    
    form_class = ['alink btn']
    form_class << options[:form_class] if options.has_key? :form_class
    
    f = ""
    f << art.idpath.in_hidden(name: 'a')
    f << operation.in_hidden(name: 'operation')
    f << button_name.in_span( class: btn_class.join(' ') )
    f.in_form onclick: "this.submit()", class: form_class.join(' '), id: options[:form_id]
  end
  alias :bouton_operation :button_operation
  
  ##
  # Pour insérer un bouton "Suivant"
  #
  # Par défaut, c'est un bouton qui porte le titre "Suivant" et s'insert
  # en bas de page. On peut utiliser les +options+ pour modifier ça.
  # +options+
  #     :button_name      Autre nom pour le bouton
  #     :top              Si true, c'est un bouton pour le haut de page
  def button_next art_path, options = nil
    options ||= {}
    btn_name = options[:button_name] || "Suivant"
    classes_css = ['nextbtn']
    classes_css << (options[:top] ? 'top' : 'bottom')
    lk = link_to( "Suivant &rarr;", art_path )
    lk = lk.in_div(class: classes_css.join(' ')) unless options[:inline]
    return lk
  end
  
  ##
  #
  # Pour construire une rangée de formulaire
  #
  # @usage      row("<libellé>", "<champ>")
  #
  #
  def row lib, val, options = nil
    options ||= {}
    if options.has_key? :class
      options[:class] = [options[:class]]
    else
      options = options.merge(class: [])
    end
    lib = '&nbsp;' if lib.nil? || lib == ""
    options[:class] << 'row'
    options[:class] = options[:class].join(' ').strip
    (lib.in_span(class: 'libelle')+val.in_span(class: 'value')).in_div(options)
  end
  
  
  ##
  #
  # @return le code pour embedder une vidéo YouTube
  #
  def video_youtube code
    <<-HTML
<iframe width="560" height="315" src="https://www.youtube.com/embed/#{code}" frameborder="0" allowfullscreen></iframe>
    HTML
  end
  
  ##
  #
  # @return le lien à l'image de path relatif +relpath+ (dans ./public/page/img)
  #
  # +attrs+ Les attributs à ajouter à la balise img
  #
  # Cf. RefBook > Article_redaction.md
  #
  def image relpath, args = nil
    args ||= {}
    
    ##
    ## Le path de l'image
    ## 
    ## Soit en local, soit sur Icare
    ##
    path_image = if args.delete(:icare)
      "http://#{url_folder_image}/#{relpath}"
    else
      File.join('.', 'public', 'page', 'img', relpath)
    end
    
    ##
    ## L'image doit-elle être cliquable ?
    ## Si oui, il faut la réduire pour qu'elle tienne dans un cadre et
    ## pouvoir cliquer pour l'aggrandir
    ##
    centree   = args.delete(:center)
    openable  = args.delete(:openable)
    offset    = args.delete(:offset)
    size      = args.delete(:size)
    positionning  = args.delete(:positionning)
    positionning = false if online?
    
    
    ##
    ## L'image doit-elle être affichée partiellement ?
    ## Cf. le mode d'emploi
    ##
    if offset
      div_style = []
      if size
        div_style << "width:#{size[0]}px"
        div_style << "height:#{size[1]}px"
      end
      div_style << 'position:relative'
      if positionning
        div_style << "border:4px solid;overflow:visible"
      else
        div_style << "overflow:hidden"
      end
      if centree
        div_style << "display:inline-block"
      end
      args.merge!(style: "position:absolute;top:-#{offset[0]}px;left:-#{offset[1]}px;z-index:-1")
      limage = path_image.in_image( args )
      limage = limage.in_div( style: div_style.join(';') )
    else
      ##
      ## Aucun offset
      ##
      limage = path_image.in_image( args )
    end
    
    if openable
      limage = ("Cliquez sur l'image pour l'aggrandir/la réduire".in_div(class: 'tiny center italic red') + limage).in_div(class: 'openable_image', onclick: "$.proxy(UI,'toggle_image',this)()") 
    end
    
    if centree
      limage = limage.in_div( class: 'center' )
    end
    
    c = ""
    c << limage
    if args.has_key? :mp3
      c << link_play( path: args.delete(:mp3), balise_audio: true, no_controls: args.delete(:no_controls) )
      c.in_div(class: 'imgmp3')
    else
      c
    end
  end
  
  ##
  #
  # @return une balise image du site Icare
  #
  def image_icare relpath, args = nil
    args ||= {}
    args.merge! :icare => true
    image relpath, args
    # args.merge! src: "http://#{url_folder_image}/#{relpath}"
    # "".in_img( args )
  end
  
  ##
  # @return un lien permettant de jouer le fichier audio
  # d'affixe +audio_affixe+ en replaçant le mot +rejouer_name+ à
  # la fin du jeu
  #
  # Note : une balise audio a dû être définie, soit avec la méthode
  # `image' (qui associe le son à une image de partition) soit avec
  # la méthode `balise_audio' qui place le son dans la page.
  #
  # +args+
  #   btn_jouer:        Le titre du lien
  #   btn_rejouer:      Le titre du lien après lecteur ("Rejouer" par défaut ou 
  #                     btn_jouer s'il est défini)
  #   path:             Le path relatif au fichier (avec ou sans .mp3)
  #                     Sauf s'il est passé en premier argument
  #   balise_audio:     Si true, on construit la balise audio. Sinon, elle doit
  #                     avoir été construite
  #   no_controls:      Ne pas mettre de lien pour jouer le fichier audio (il
  #                     sera placé ailleurs)
  #
  def link_play path_or_args, args = nil
    case path_or_args
    when Hash 
      args = path_or_args
      path = args.delete(:path)
    else
      path = path_or_args
      args ||= {}
    end
    
    btn_rejouer   = args.delete(:btn_rejouer) || args[:btn_jouer] || "Rejouer"
    btn_jouer     = args.delete(:btn_jouer) || "Écouter"
    path_affixe   = File.join( File.dirname(path), File.basename(path, File.extname(path) ) )
    audio_id      = "mp3_#{path_affixe.gsub(/[\/\.:\-]/,'_')}"
    link_a_id     = "btn_audio#{audio_id}"
    onclick       = "$.proxy(UI.Audio.new('#{audio_id}', '#{btn_rejouer}'), 'play')()"
    
    c = ""
    c << balise_audio(audio_id, path) if args[:balise_audio]
    c << btn_jouer.in_a(id: link_a_id, onclick: onclick, class: 'mp3') unless args[:no_controls]

    return c
  end
  
  ##
  # Emplacement des fichiers sons, pour les atteindre par une
  # URL externe
  # 
  # Pour le moment, les sons sont placés sur l'atelier icare
  # 
  def url_folder_sounds
    @url_folder_sounds ||= "www.atelier-icare.net/sound/cp"
  end
  
  ##
  #
  # Emplacement des fichiers PNG sur icare
  #
  def url_folder_image
    @url_folder_image ||= "www.atelier-icare.net/img/cp_score"
  end
  
  ##
  # @return une balise audio pour le son de path ou d'affixe-path +mp3+
  #
  def balise_audio audio_id, path
    path.concat('.mp3') unless path.end_with? '.mp3'
    <<-HTML
<audio id="#{audio_id}" class='mp3'>
  <source src="http://#{url_folder_sounds}/#{path}" type='audio/mpeg'>
</audio>
    HTML
  end
  
  ##
  #
  # @return une balise “<a name”, une ancre
  #
  #
  def ancre name
    "<a name='#{name}'></a>"
  end
  alias :aname :ancre
  
  ##
  #
  # @return une lien vers l'ancre +name+ avec le titre +titre+
  #
  def link_ancre titre, name, path_article = nil
    if path_article.nil?
      titre.in_a(href: "##{name}")
    else
      titre.in_a(href: "?a=#{CGI::escape path_article}##{name}")
    end
  end
  alias :link_to_ancre :link_ancre
  
  def signature
    "LCP"
  end
end