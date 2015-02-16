# encoding: UTF-8
class User
  
  ##
  ## ID du membre
  ##
  attr_reader :id
  
  ##
  ## ID unique et absolu de lecteur
  ##
  attr_reader :uid
  
  def initialize user_id = nil
    @id = if user_id.to_s.strip == ""
      nil 
    else
      user_id.to_i
    end
    define_uid
  end
  
  ##
  #
  # Méthode appelée à l'instanciation de User pour définir
  # @uid quel que soit l'user, à partir du moment où il est
  # trustable.
  #
  # La méthode associe aussi la session actuelle à l'UID de
  # lecteur.
  #
  def define_uid
    return unless trustable?

    ##
    ## Est-ce que l'id (si défini), la session-id ou la remote-ip
    ## permettent de retrouver l'UID ?
    ##
    [id, app.session.id, remote_ip].each do |uref|
      next if uref.nil?
      uid_checked = get_uid_with uref
      unless uid_checked.nil?
        @uid = uid_checked
        return
      end
    end
    
    ##
    ## Si l'UID n'a pas pu être retrouvé, on doit créer un
    ## nouveau lecteur. Noter que si c'est un membre par exemple
    ## qui se connecte à partir d'un autre ordinateur, un nouvel
    ## UID lui sera attribué. Il ne sera connu qu'au moment où
    ## il s'identifiera comme membre.
    ##
    @uid = created_as_lecteur
    
    ##
    ## On crée les pointeurs
    ##
    create_pointeurs
    
    ##
    ## Si l'user est un membre, on enregistre son UID dans ses
    ## données
    ##
    if membre?
      set(:uid => @uid) 
      debug "* Enregistrement de l'UID #{new_uid} dans les données du membres"
    end
    
    # ##
    # ## La première fois qu'on demande l'UID, il faut enregistrer
    # ## l'id de session courante dans les données du lecteur si nécessaire
    # ##
    # ## Noter que la méthode en profite aussi pour faire quelques vérifications
    # ## sur les pointeurs, et détruit celui d'après l'ancien session-id s'il
    # ## existe.
    # ##
    # save_session_id
    
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
    check_as_membre
    ##
    ## Enregistrement de la date de dernière connexion
    ##
    set_last_connexion
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