# encoding: UTF-8
=begin

Méthode App#view  et Sous-classe App::View pour gérer les vues quelles qu'elles
soit, principales ou incluses.

=end
class App
  
  
  ##
  #
  # @return le code HTML d'une vue (qui doit se trouver dans ./public/page)
  #
  def view path, bindee = nil
    begin
      View::new(path, bindee).output
    rescue RedirectError => e
      ##
      ## En cas de redirection dans la vue
      ##
      ""
    rescue Exception => e
      debug "ERREUR FATALE AVEC VUE #{path} : #{e.message}"
      debug e.backtrace.join("\n") if offline?
      e.message
    end
  end
  
  def logo_masked?
    titres_masked? || param('cb_mask_logo') == 'on'
  end
  def titres_masked?
    param('cb_mask_titres') == 'on'
  end
  def liens_tdm_masked?
    param('cb_mask_liens_tdm') == 'on'
  end
  
  # ---------------------------------------------------------------------
  #
  #   Class App::View
  #
  # ---------------------------------------------------------------------
  class View
    
    attr_reader :relpath
    attr_reader :bindee
    
    def initialize path, bindee = nil
      path.concat(".erb") unless path.end_with? '.erb'
      @relpath = path
      @bindee  = bindee
    end
    def path
      @path ||= File.join('.', 'public', 'page', relpath)
    end
    def output
      app.add_css path_css  if File.exist? path_css
      app.add_js  path_js   if File.exist? path_js
      add_all_in_folder     if File.exist? folder_article
      ERB.new(File.read(path).force_encoding('UTF-8')).result(bindee || app.bind)
    end
    def path_js
      @path_js ||= File.expand_path( File.join(dirname, "#{affixe}_mini.js") )
    end
    def path_css
      @path_css ||= File.expand_path( File.join(dirname, "#{affixe}.css") )
    end
    
    ##
    #
    # Chargement de tous les éléments du dossier au même niveau que
    # la vue ERB, contenant les css, js et rb
    #
    def add_all_in_folder
      Dir["#{folder_article}/**/*.rb"].each { |m| require m }
      app.add_css Dir["#{folder_article}/**/*.css"]
      app.add_js Dir["#{folder_article}/**/*_mini.js"]
    end
    
    ##
    #
    # Le "dossier-article". C'est un dossier au même niveau que
    # le fichier ERB qui peut contenir css, js et modules ruby
    #
    def folder_article
      @folder_article ||= File.join(dirname, affixe)
    end
    
    def affixe
      @affixe ||= File.basename( relpath, File.extname(relpath) )
    end
    def dirname
      @dirname ||= File.dirname(path)
    end
    
    
    
  end
 
end