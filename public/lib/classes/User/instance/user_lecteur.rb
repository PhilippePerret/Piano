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
    ## Avant de le créer, il faut voir si ce n'est pas un
    ## user déjà connu, mais pas encore tout à fait identifié, par
    ## exemple un membre qui arrive sur le site, mais qui ne s'est
    ## pas encore identifié.
    ##
    uid_checked = get_uid_with app.session.id
    if uid_checked.nil?
      uid_checked = get_uid_with remote_ip
    end
    return uid_checked unless uid_checked.nil?

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
    
    new_uid = nil
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
        membre:         membre?,
        follower:       follower?,
        last_connexion: Time.now.to_i,
        last_vote:      nil,
        articles_noted: []
      }
      debug "Création d'un nouveau lecteur : {"+
        ps[new_uid].collect{|k,v| "#{k.inspect} => #{v.inspect}"}.join("\n") + "}"
    end
    
    ##
    ## On crée les pointeurs
    ##
    create_pointeurs_to new_uid
    
    ##
    ## Si l'user est un membre, on enregistre son UID dans ses
    ## données
    ##
    if membre?
      set(:uid => new_uid) 
      debug "* Enregistrement de l'UID #{new_uid} dans les données du membres"
    end
    
    return new_uid
  end
  ##
  #
  # Attribue un UID unique et absolu pour l'user et LE RETOURNE
  #
  def create_pointeurs_to new_uid
    return nil unless trustable?
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      ps[id]              = new_uid if membre?
      ps[mail]            = new_uid if membre? || follower?
      ps[remote_ip]       = new_uid
      ps[app.session.id]  = new_uid unless app.session.nil? # tests
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
    PStore::new(app.pstore_lecteurs).transaction { |ps| ps[uid][:session_id] = app.session.id }    
    
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|

      ##
      ## Destruction de l'ancien pointeur
      ##
      unless old_session_id.nil?
        ps.delete(old_session_id)
        debug "* Destruction de l'ancien pointeur vers #{uid} (uid) de l'ancienne session-id : #{old_session_id}"
      end

      ##
      ## Ajout du nouveau pointeur
      ##
      ps[new_session_id] = uid
      debug "= Nouveau pointeur sur #{uid} (uid) depuis session-id #{new_session_id}"

      ##
      ## On vérifie que le pointeur par la remote-addr est bien définie
      ## Sinon, on crée aussi ce pointeur.
      ##
      if ps.fetch(remote_ip, nil).nil?
        ps[remote_id] = uid
        debug "= Nouveau pointeur sur #{uid} (uid) depuis remote_id #{remote_id}"
      end
      
      ##
      ## Si c'est un membre, on vérifie que le pointeur par son
      ## ID de membre est bien défini
      ##
      if membre?
        if ps.fetch(id, nil).nil?
          ps[id] = uid
          debug "= Nouveau pointeur sur #{uid} (uid) depuis l'id du membre #{id.inspect}"
        end
      end
    end
    
    
  end
  
  
end