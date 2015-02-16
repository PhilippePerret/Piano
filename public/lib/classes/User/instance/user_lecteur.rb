# encoding: UTF-8
=begin

Méthodes d'instance User gérant l'user comme lecteur

=end
class User
  
  ##
  #
  # Retourne les données de l'User en tant que lecteur, c'est-à-dire
  # membre, follower ou même simple user trustable
  #
  def data_as_lecteur
    return nil unless trustable?
    @data_as_lecteur ||= begin
      uid # au cas où…
      PStore::new(app.pstore_lecteurs).transaction { |ps| ps[uid] }
    end
  end
  
  
  ##
  #
  # Crée l'user comme lecteur et retourne son UID
  #
  def created_as_lecteur
    return nil unless trustable?
    ##
    ## ID qui sera consigné
    ##
    id_intbl = case true
    when membre?    then id
    when follower?  then mail
    else nil
    end
  
    ##
    ## Type de l'user
    ##
    type_intbl = case true
    when membre?    then :membre
    when follower?  then :follower
    else nil
    end
    
    is_membre   = true == membre?
    is_follower = true == follower?
    
    new_uid   = nil
    new_data  = nil
    PStore::new(app.pstore_lecteurs).transaction do |ps|
      new_uid = ps.fetch(:last_uid, 0) + 1 
      ps[:last_uid] = new_uid

      ##
      ## Données enregistrées comme lecteur
      ## 
      ## Note : elle pourront être modifiées lorsque le simple user
      ## change de statut (-> follower -> membre)
      ##
      ps[new_uid] = {
        uid:            new_uid,
        type:           type_intbl,   # :membre, :follower ou nil
        id:             id_intbl,     # id (membre) mail (follower) ou nil
        membre:         is_membre,
        follower:       is_follower,
        last_connexion: Time.now.to_i,
        last_vote:      nil,
        articles_noted: []
      }
      new_data = ps[new_uid]
    end
    
    return new_uid
  end
  ##
  #
  # Enregistre les pointeurs vers l'UID après l'avoir déterminé
  #
  def create_pointeurs
    return nil unless trustable?
    raise "@uid devrait être défini pour créer les pointeurs…" if uid.nil?
    is_membre   = true == membre?
    is_follower = true == follower?
    session_id  = app.session.id
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      ps[remote_ip]   = uid
      ps[session_id]  = uid unless session_id.nil? # tests
      ps[id]          = uid if is_membre
      ps[mail]        = uid if is_membre || is_follower
    end
  end
 
  ##
  #
  # Enregistrement de la session ID du lecteur courant, quel qu'il
  # soit.
  #
  # Si la session est différente de la session précédemment enregistrée,
  # il faut actualiser aussi le pointeur (qui porte en clé la dernière
  # session de l'user).
  #
  # Quand c'est un follower, ou un membre, on en profite pour vérifier 
  # que son pointeur par sa remote_ip soit bien définie.
  #
  def save_session_id
    return
    ##
    ## Rien à faire si la session enregistrée est la session
    ## courante
    ##
    return if data_as_lecteur[:session_id] == app.session.id
    
    ##
    ## On récupère l'ancienne session enregistrée pour pouvoir
    ## détruire le pointeur.
    ##
    old_session_id = data_as_lecteur[:session_id]
    
    ##
    ## Le nouvel ID de session
    ##
    new_session_id = app.session.id
    
    ##
    ## On le met tout de suite dans la variable
    ## volatile.
    ##
    @data_as_lecteur[:session_id] = new_session_id
    
    ##
    ## Pour une nouvelle session, il faut la définir dans les données,
    ## définir un pointeur et peut-être supprimer le pointeur précédent
    ##
    PStore::new(app.pstore_lecteurs).transaction { |ps| ps[uid][:session_id] = new_session_id }    
    
    this_uid = uid
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|

      ##
      ## Destruction de l'ancien pointeur
      ##
      unless old_session_id.nil?
        ps.delete(old_session_id)
        debug "* Destruction de l'ancien pointeur vers #{this_uid} (uid) de l'ancienne session-id : #{old_session_id}"
      end

      ##
      ## Ajout du nouveau pointeur
      ##
      ps[new_session_id] = uid
      debug "= Nouveau pointeur sur #{this_uid} (uid) depuis session-id #{new_session_id}"

      ##
      ## On vérifie que le pointeur par la remote-addr est bien définie
      ## Sinon, on crée aussi ce pointeur.
      ##
      if ps.fetch(remote_ip, nil).nil?
        ps[remote_id] = uid
        debug "= Nouveau pointeur sur #{this_uid} (uid) depuis remote_ip #{remote_ip}"
      end
      
      ##
      ## Si c'est un membre, on vérifie que le pointeur par son
      ## ID de membre est bien défini
      ##
      if membre?
        if ps.fetch(id, nil).nil?
          ps[id] = uid
          debug "= Nouveau pointeur sur #{this_uid} (uid) depuis l'id du membre #{id.inspect}"
        end
      end
    end
    
    
  end
  
  ##
  #
  # Méthode de désinscription de l'user
  #
  # Note: la méthode est le plus naturelle appelée par un
  # ticket appelé par un lien dans le mail
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
    
    ##
    ## Destruction dans la table des pointeurs de lecteurs
    ##
    session_id = app.session.id
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      unless ps.fetch(remote_ip, :unfound) == :unfound
        ps.delete remote_ip
        debug "= Suppression de pointeur remot_ip"
      end
      unless ps.fetch(mail, :unfound) == :unfound
        ps.delete mail
        debug "= Suppression de pointeur mail"
      end
      unless ps.fetch(session_id, :unfound) == :unfound
        ps.delete session_id
        debug "= Suppression de pointeur session-id"
      end
    end
    debug "= Fin de suppression des pointeurs"
    
    
    flash "Votre désinscription a bien été prise en compte. Désolé de ne plus vous compter parmi nous."
  end
end