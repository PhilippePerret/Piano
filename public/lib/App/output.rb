# encoding: UTF-8
class App
  
  ##
  #
  # = main =
  #
  # Produit le code retourné au client
  #
  def output
    cgi.out{ cgi.html { code_html } }
    new_connexion
  end 
  
  ##
  #
  # @return l'instance CGI
  #
  def cgi
    @cgi ||= CGI::new('html4')
  end
  ##
  #
  # @return le code HTML complet de la page
  #
  def code_html
    ERB.new(File.read('./public/page/gabarit.erb').force_encoding('UTF-8')).result(bind)
  end
    
  def debug str = nil
    if str.nil?
      # => Retourne le contenu du debug
      return "" if @debugs.nil?
      debug_str = @debugs.join("\n")
      "<div style='clear:both;'></div><pre id='debug'>#{debug_str}</pre>"
    else
      # => Ajoute un message de débug
      @debugs ||= []
      @debugs << str
    end
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
    end.join("\n")
  end
  def traite_folder_js path
    Dir["#{path}/**/*_mini.js"].collect do |js|
      "<script type='text/javascript' src='#{relative_path js}' charset='utf-8'></script>"
    end.join("\n")
  end
  
end