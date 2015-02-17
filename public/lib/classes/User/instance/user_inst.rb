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
    define_uid if @id != nil || ENV['REMOTE_ADDR'] != nil
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
    ##
    ## Est-ce que l'id (si défini), la session-id ou la remote-ip
    ## permettent de retrouver l'UID ? (pointeurs)
    ##
    ## Note: Ne surtout pas utiliser mail ou @mail ici qui ne peut
    ## être défini que si c'est un membre.
    ##
    @uid = nil
    [id, app.session.id, remote_ip].each do |uref|
      next if uref.nil?
      uid_checked = get_uid_with uref
      unless uid_checked.nil?
        @uid = uid_checked
        break
      end
    end
    
    ##
    ## Si @uid est nil, il faut créer le lecteur courant
    ##
    ## Noter que ça peut très bien être un membre ou un follower
    ## pas encore identifié
    ##
    if @uid.nil?
      
      ##
      ## Si l'UID n'a pas pu être retrouvé, on doit créer un
      ## nouveau lecteur. Noter que si c'est un membre par exemple
      ## qui se connecte à partir d'un autre ordinateur, un nouvel
      ## UID lui sera attribué. Il ne sera connu qu'au moment où
      ## il s'identifiera comme membre.
      ##
      @uid = create_as_reader
    
      ##
      ## On crée les pointeurs
      ##
      create_pointeurs
    
      ##
      ## Si l'user est un membre, on enregistre son UID dans ses
      ## données
      ##
      set(:uid => @uid) if membre?

    else # si @uid est défini
      
      ##
      ## Quand @uid a été trouvé, il faut vérifier que le lecteur
      ## possède bien des données, ce qui n'est pas le cas parfois en
      ## cas d'erreur
      ##
      
    end
    
    ##
    ## Il faut enregistrer l'id de session courante dans les données
    ## du lecteur si nécessaire (c'est-à-dire si elle a changé)
    ##
    ## En cas de changement de session-id, la méthode détruit aussi l'ancien
    ## pointeur session-id et crée le nouveau, puisque ça n'a été fait 
    ## ci-dessus que si le lecteur a dû être créé.
    ##
    update_session_id_if_needed
    
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