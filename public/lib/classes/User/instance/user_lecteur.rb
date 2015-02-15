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