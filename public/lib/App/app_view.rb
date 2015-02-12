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
    rescue Exception => e
      debug "ERREUR FATALE AVEC VUE #{path} : #{e.message}"
      debug e.backtrace.join("\n") if offline?
      e.message
    end
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
      app.add_css path_css if File.exist? path_css
      app.add_js  path_js  if File.exist? path_js
      ERB.new(File.read(path).force_encoding('UTF-8')).result(bindee || app.bind)
    end
    def path_js
      @path_js ||= File.expand_path( File.join(dirname, "#{affixe}_mini.js") )
    end
    def path_css
      @path_css ||= File.expand_path( File.join(dirname, "#{affixe}.css") )
    end
    def affixe
      @affixe ||= File.basename( relpath, File.extname(relpath) )
    end
    def dirname
      @dirname ||= File.dirname(path)
    end
  end
 
end