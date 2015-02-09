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
  # @return le code HTML d'une vue (qui doit se trouver dans ./public/page)
  #
  def view path, bindee = nil
    begin
      path.concat(".erb") unless path.end_with? '.erb'
      real_path = File.join('.', 'public', 'page', path)
      ERB.new(File.read(real_path).force_encoding('UTF-8')).result(bindee || bind)
    rescue Exception => e
      debug "ERREUR FATALE AVEC VUE #{path} : #{e.message}"
      debug e.backtrace.join("\n") if offline?
      e.message
    end
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
      @debugs ||= []
      @debugs << str
    end
  end
  
  ##
  #
  # @return le code HTML pour les feuilles de styles
  #
  def stylesheets
    Dir["./public/page/css/**/*.css"].collect do |css|
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