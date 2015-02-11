# encoding: UTF-8
require 'cgi/session'
class App
  
  ##
  #
  # La session courante (instance App::Session)
  #
  #
  def session
    @session ||= App::Session::new(self)
  end
  
  class Session
    
    attr_reader :app
    
    attr_reader :scgi
    def initialize app
      @app = app
    end
    
    ##
    #
    # La session CGI::Session
    #
    #
    def scgi
      @scgi ||= CGI::Session::new(
        app.cgi,
        'session_key'       => "CERCPIA", # (= nom cookie)
        'session_expires'   => Time.now + 60 * 60,
        'prefix'            => 'cercpia'
      )
    end
    
    ##
    #
    # Récupère une valeur de session
    #
    # @usage: <value> = app.session[<key>]
    #
    def [] key
      scgi[key]
    end
    
    ##
    #
    # Définit une valeur de session
    #
    # @usage:   app.session[<key>] = <value>
    #
    def []= key, value
      scgi[key] = value
    end
    
    ##
    #
    # ID de la session
    #
    #
    def id
      @id ||= scgi.session_id
    end
  
  
    ##
    #
    # Destruction de la précédente session (sécurité)
    #
    #
    def delete_last
      begin
        CGI::Session.new(app.cgi, 'new_session' => false).delete
      rescue ArgumentError
      end
    end
    
  end
end