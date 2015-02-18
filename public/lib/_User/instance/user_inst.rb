# encoding: UTF-8
class User
  
  ##
  ## ID du membre
  ##
  attr_reader :id
  
  ##
  ## ID unique et absolu de lecteur
  ##
  attr_accessor :uid
  
  ##
  #
  # Instanciation d'un User
  #
  # Penser que cette méthode n'est pas seulement appelée pour
  # les visiteurs, mais aussi pour récupérer une instance d'user
  # lors de certaines opérations, même lorsque ce n'est pas
  # l'administrateur (pour voir la liste des membres par exemple)
  #
  def initialize user_id = nil
    @id = if user_id.to_s.strip == ""
      nil 
    else
      user_id.to_i
    end
  end
  
  ##
  #
  # Méthode appelée à LA TOUTE PREMIER CONNEXION du visiteur pour
  # lui donner un @uid, à partir du moment où il est
  # "trustable".
  #
  def define_uid
    debug "-> define_uid"
    
    ##
    ## Barrière untrustable user
    ##
    return if ENV['REMOTE_ADDR'].to_s == ""

    ##
    ## On essaie de récupère l'UID par la remote_ip
    ## Si on ne le trouve pas, on crée un nouveau
    ## reader
    ##
    self.uid = get_uid_via_pointeur_ip
    if uid.nil?
      self.uid = create_as_reader
      create_pointeur_ip
      debug "= Création d'un nouveau reader (IP introuvable) : UID #{uid}"
    else
      debug "= Reader retrouvé par son IP : #{uid} (UID)"
    end
    
    ##
    ## On met l'UID en session
    ##
    ## Cf. voir s'il faut le faire ici ou plutôt dans
    ## User::retrieve_user (je ne sais pas si les variables
    ## session définies une fois reste toujours, c'est le
    ## moyen de le savoir)
    ##
    app.session['reader_uid'] = uid
    
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
  def remote_ip
    @remote_ip ||= app.cgi.remote_addr
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
    store( 
      :session_id => app.session.id,
      :user_type  => :membre,
      :membre_id  => id
      )
    app.session['user_id']  = id
    @is_identified          = true
    
    
    ##
    ## Vérification du membre
    ##
    check_as_membre

    flash "Bienvenue, #{pseudo} !"
    
  end
  
  ##
  #
  # Déconnexion du membre
  #
  #
  def logout
    store :deconnexion => Time.now.to_i
    User::current                 = nil
    app.session['user_id']        = nil
    app.session['reader_uid']     = nil
    app.session['follower_mail']  = nil # on sait jamais…
    @is_identified                = false
    @uid  = nil
    @id   = nil
  end
  
  def app
    @app ||= App::current
  end
    
  def bind; binding() end
  
end