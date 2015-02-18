# encoding: UTF-8
=begin

Méthodes d'instance User gérant l'user comme lecteur

=end
class User
  
  ##
  #
  # = main =
  #
  # Enregistre des valeurs dans le pstore readers.pstore
  #
  # Noter qu'en général, il vaut mieux enregistrer dans le
  # pstore provisoire de l'user. Mais certaines valeurs, comme
  # par exemple le vote pour l'ordre des articles ou les
  # articles déjà notés nécessitent d'avoir une "vraie" valeur
  #
  def store_reader hdata
    return nil unless trustable?
    PStore::new(app.pstore_readers).transaction do |ps|
      hdata.each { |k, v| ps[uid][k] = v }
    end
  end
  
  ##
  #
  # = main = 
  #
  # Retourne une valeur se trouvant dans le pstore
  # readers.pstore, en se servant de l'UID de l'user
  #
  def destore_reader key
    return nil unless trustable?
    PStore::new(app.pstore_readers).transaction do |ps|
      ps[uid][key]
    end
  end
  
  ##
  #
  # Retourne les données de l'User en tant que lecteur, c'est-à-dire
  # membre, follower ou même simple user trustable
  #
  def data_reader
    return nil unless trustable?
    @data_reader ||= begin
      PStore::new(app.pstore_readers).transaction { |ps| ps.fetch uid, nil }
    end
  end
    
  ##
  #
  # Crée l'user comme lecteur et retourne son UID
  #
  # Noter que la méthode n'est appelée que lors de la
  # toute première connexion de SESSION de l'user.
  # Quel que soit l'utiliser, un reader est créé, qui
  # pourra ensuite être détruit (par cron) si on le
  # reconnait comme user connu.
  #
  def create_as_reader
    return nil unless trustable?
    ##
    ## Définir un nouvel UID de lecteur
    ##
    new_uid = nil
    PStore::new(app.pstore_readers).transaction do |ps|
      if new_uid.nil?
        new_uid = ps.fetch(:last_uid, 0) + 1 
        ps[:last_uid] = new_uid
      end
      ##
      ## Données enregistrées comme lecteur
      ##
      ps[new_uid] = default_data.merge(uid: new_uid)
    end
    
    return new_uid
  end
  
  ##
  # Données par défaut pour le reader
  #
  def default_data
    now = Time.now.to_i
    {
      uid:            nil,
      type:           nil,      # :membre, :follower ou nil
      id:             nil,      # id (membre) mail (follower) ou nil
      membre:         false,
      follower:       false,
      last_connexion: now,
      last_vote:      nil,
      articles_noted: [],
      session_id:     app.session.id,
      created_at:     now
    }
  end
  
  ##
  #
  # Retourne l'UID reader vers lequel pointe l'IP de l'user
  # ou NIL si cet IP est inconnu
  #
  # Note: Cette méthode n'est appelée qu'à la toute première
  # connexion (début session) de l'user
  #
  def get_uid_via_pointeur_ip
    return nil unless trustable?
    PStore::new(app.pstore_ip_to_uid).transaction do |ps|
      ps.fetch( remote_ip, nil)
    end
  end
  
  ##
  #
  # Enregistre les pointeurs IP -> UID
  #
  # Note : la méthode n'est appelée que si le pointeur IP n'a
  # pas été trouvé.
  #
  def create_pointeur_ip
    return nil unless trustable?
    PStore::new(app.pstore_ip_to_uid).transaction do |ps|
      ps[remote_ip] = uid
      debug "Nouveau pointeur #{remote_ip} (remote_ip) -> #{uid} (uid)"
    end
  end
 
  ##
  #
  # Enregistrement de la session ID du lecteur courant, quel qu'il
  # soit.
  #
  # Si la session est différente de la session précédemment enregistrée
  # dans les données lecteurs, il faut actualiser aussi le pointeur 
  # (qui porte en clé la dernière session de l'user) et détruire
  # l'ancien pointeur session-id
  #
  # N'EST PLUS APPELÉE POUR LE MOMENT
  #
  def update_session_id_if_needed
    ##
    ## Rien à faire si la session enregistrée est la session
    ## courante
    ##
    return if data_reader[:session_id] == app.session.id
    
    ##
    ## On récupère l'ancienne session enregistrée pour pouvoir
    ## détruire le pointeur.
    ##
    old_session_id = data_reader[:session_id]
    
    ##
    ## Le nouvel ID de session
    ##
    new_session_id = app.session.id
    
    ##
    ## On le met tout de suite dans la variable
    ## volatile.
    ##
    @data_reader[:session_id] = new_session_id
    
    ##
    ## Pour une nouvelle session, il faut la définir dans les données
    ## du lecteur.
    ##
    PStore::new(app.pstore_readers).transaction do |ps| 
      ps[uid][:session_id] = new_session_id
      debug "= Enregistrement de la session-id dans les données du lecteur (#{new_session_id})"
    end
    
    ##
    ## Ajout du pointeur de session-id et destruction de l'ancien
    ## s'il existait.
    ##
    PStore::new(app.pstore_ip_to_uid).transaction do |ps|
      ps[new_session_id] = uid
      ps.delete(old_session_id) unless old_session_id.nil?
      debug "= Actualisation du pointeur de session-id"
    end
    
  end  
  
  ##
  #
  # Méthode de désinscription de l'user
  #
  # Note: la méthode est le plus naturelle appelée par un
  # ticket appelé par un lien dans le mail
  #
  # Note : On ne détruit pas son pointeur IP, pour garder
  # sa donnée reader
  #    
  def unsubscribe
    debug "-> unsubscribe"
    
    ##
    ## Destruction dans la table des followers
    ##
    PStore::new(app.pstore_followers).transaction do |ps|
      unless ps.fetch(mail, :unfound) == :unfound
        ps.delete mail
        debug "= Suppression de table des followers OK"
      end
    end
    
    flash "Votre désinscription a bien été prise en compte. Désolé de ne plus vous compter parmi nous."
  end
end