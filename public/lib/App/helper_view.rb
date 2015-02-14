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
  def image relpath, args = nil
    File.join('.', 'public', 'page', 'img', relpath).in_image( args )
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
  
  def signature
    "LCP"
  end
end