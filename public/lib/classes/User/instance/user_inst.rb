# encoding: UTF-8
class User
  
  attr_reader :id
  
  def initialize user_id = nil
    @id = if user_id.to_s.strip == ""
      user_id = nil 
    else
      user_id.to_i
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes-propriétés volatiles
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Adresse IP de l'user (identifié ou non)
  #
  # Consigne aussi cette connexion dans ips.pstore
  # Noter que cette remote ip n'est pas sûre du tout, puisque
  # les constantes HTTP_CLIENT_IP et HTTP_X_FORWARDED_FOR peuvent
  # être falsifiées. La méthode trustable? ne tient compte que de
  # la REMOTE_ADDR.
  #
  def remote_ip
    @remote_ip ||= begin
      raddr   = ENV['REMOTE_ADDR']
      httpid  = ENV['HTTP_CLIENT_IP']
      httpx   = ENV['HTTP_X_FORWARDED_FOR']
      ip = raddr || httpid || httpx # TODO: affiner
      app.remember_ip ip
      ip
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Identifie l'user
  #
  # On enregistre l'ID de session courante dans ses données, on
  # met son identifiant dans 'user_id' de la session, pour pouvoir
  # le reconnaitre au prochain chargement de page.
  # On indique aussi sa dernière date de connexion au site.
  #
  # On profite aussi de ce login pour faire un check de l'utilisateur
  # Cf. check_as_membre
  #
  def login
    User::current = self
    set :session_id => app.session.id
    app.session['user_id']  = id
    @is_identified          = true
    flash "Bienvenue, #{pseudo} !"
    ##
    ## Vérification du membre
    ##
    # check_as_membre
    ##
    ## Enregistrement de la date de dernière connexion
    ##
    # set_last_connexion
  end
  
  ##
  #
  # Déconnexion du membre
  #
  #
  def logout
    User::current           = nil
    set :session_id        => nil
    app.session['user_id']  = nil
    @is_identified          = false
  end
  
  def app
    @app ||= App::current
  end
    
  def bind; binding() end
  
end