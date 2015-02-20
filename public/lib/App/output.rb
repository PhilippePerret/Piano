# encoding: UTF-8
class App
  
  ##
  #
  # = main =
  #
  # Produit le code retourné au client
  #
  def output
    if param('ajx') != "1"
      # => Mode normal
      connexions.add
      cgi.out{ cgi.html { code_html } }
    else
      # => Mode ajax
      output_ajax
    end
  end 
  
  ##
  #
  # Retour quand on est en mode ajax
  #
  attr_accessor :data_ajax
  def output_ajax
    require 'json'
    self.data_ajax ||= {}
    ##
    ## Mettre les messages ET les erreurs dans :message
    ##
    self.data_ajax.merge!(:message => messages) unless messages == ''
    STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
    STDOUT.write self.data_ajax.to_json
  end
  
  
  ##
  #
  # @return le titre pour la balise TITLE de HEAD
  #
  def title
    tit = article.titre
    if tit.to_s.strip == "" && article.name != "_tdm_.erb"
      tit = "Accueil" 
      ## TODO: Affiner le traitement ici en testant les article.idpath
      ## particulière.
    end
    return tit
  end
  
  ##
  #
  # @return le code HTML complet de la page
  #
  def code_html
    ERB.new(File.read('./public/page/gabarit.erb').force_encoding('UTF-8')).result(bind)
  end
  
  ##
  #
  # Ajoute une ou des feuilles de styles CSS
  #
  #
  def add_css stylesheets
    stylesheets = [stylesheets] unless stylesheets.class == Array
    @css_added ||= []
    @css_added += stylesheets
  end
  
  ##
  #
  # Ajoute un ou des scripts javascript
  #
  #
  def add_js jss
    jss = [jss] unless jss.class == Array
    @js_added ||= []
    @js_added += jss
  end
  
  ##
  #
  # Retourne les feuilles de style ajoutées
  #
  def css_added
    @css_added ||= []
  end
  
  ##
  #
  # @return le code HTML pour les feuilles de styles
  #
  def stylesheets
    ( Dir["./public/page/css/**/*.css"] + css_added ).collect do |css|
      "<link rel='stylesheet' href='./#{relative_path css}' type='text/css' media='screen' charset='utf-8'>"
    end.join("\n")
  end
  
  ##
  #
  # @return le code HTML pour les javascripts
  #
  def javascripts
    [:first_required, :required].collect do |folder_name|
      traite_folder_js("./public/page/js/#{folder_name}")
    end.join("\n") +
    (@js_added.nil? ? "" : @js_added.collect{|p| balise_js(p) }.join(''))
  end
  def traite_folder_js path
    Dir["#{path}/**/*_mini.js"].collect do |js| balise_js js end.join('')
  end
  def balise_js pathjs
    "<script type='text/javascript' src='#{relative_path pathjs}' charset='utf-8'></script>"
  end
end