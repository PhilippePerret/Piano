# encoding: UTF-8
=begin

Méthodes d'instances User utilitaires

=end
class User
  
  ##
  #
  # Envoyer un mail à l'user
  #
  # Cette méthode est à utiliser lorsqu'on n'a qu'un seul mail
  # à envoyer, seulement à ce membre/follower
  #
  # +data_mail+ doit contenir au minium :
  #   :subject    Le sujet
  #   :message    Le message
  #
  def send_mail data_mail
    app.require_library 'mail'
    Mail::new(data_mail).send
  end
  
  ##
  #
  # Enregistre la date de dernière connexion
  #
  # Elle est enregistrée dans les data lecteur, pas dans les
  # data du membre, donc elle est utilisable pour tout user
  # quel qu'il soit.
  #
  def set_last_connexion
    return unless trustable?
    set_as_reader :last_connexion => Time.now.to_i
  end
  
  

  ##
  #
  # Procède au check d'un user-membre qui vient de s'identifier
  #
  #   * Vérifie les pointeurs pour l'UID
  #   * Vérifie que les données lecteurs soient valides
  #   * Pour un administrateur, vérifie s'il y a des opérations
  #     à effectuer
  #
  #
  def check_as_membre
    ##
    ## Régler la valeur de l'UID s'il n'est pas défini
    ##
    set( :uid => uid ) if get(:uid).nil?
    
    ##
    ## Régler son adresse IP si elle n'est pas définie
    ##
    set( :remote_ip => remote_ip ) if get(:remote_ip).nil?
    
    ##
    ## En offline, on rappatrie le pstore des handlers de readers
    ##
    if offline?
      fichier_pointeurs = Fichier::new(app.pstore_readers_handlers)
      fichier_pointeurs.download
      debug "= Fichier des pointeurs lecteurs downloadé en local"
    end
    
    
    modified = false
    PStore::new(app.pstore_readers_handlers).transaction do |ps|
      checked_mail = ps.fetch(mail, nil)
      if checked_mail.nil? || checked_mail != uid
        ps[mail] = uid
        debug "= Pointeur lecteur mail -> uid ajouté (#{mail} -> #{uid})"
        modified = true
      end
      # Note: pour la remote_ip, il ne faut pas faire comme avec le
      # mail car l'utilisateur peut avoir plusieur remote_ip
      if ps.fetch(remote_ip, nil).nil?
        ps[remote_ip] = uid
        debug "= Pointeur lecteur remote_ip -> uid ajouté (#{remote_ip} -> #{uid})"
        modified = true
      end
      # Note : le session-id sera ajouté ou a été ajouté autrement
    end
    
    ##
    ## Si des modifications ont été faites en offline, on uploade
    ## le fichier sur le site distant
    ##
    if offline? && modified
      flash "Les données des pointeurs lecteurs ont été modifiées. Il serait bon d'uploader le pstore pstore_readers_handlers.pstore APRÈS AVOIR VÉRIFIÉ LES INFORMATIONS."
    end

    ##
    ## En Offline, il faut rappatrier le fichier distant
    ##
    if offline?
      fichier = Fichier::new app.pstore_readers
      fichier.download
      debug "= Fichier distant des data lecteurs downloadé"
    end
    
    ##
    ## Les informations lecteur du membre sont-elles
    ## valides ?
    ##
    modified = false
    PStore::new(app.pstore_readers).transaction do |ps|
      dlec = ps[uid]
      unless dlec[:type] == :membre
        ps[uid][:type] = :membre
        debug "= :type du membre mis à :membre dans les data lecteur"
        modified = true
      end
      unless dlec[:id] == id
        ps[uid][:id] = id
        debug "= :id du membre mis à #{id} dans les data lecteur"
        modified = true
      end
      unless dlec[:membre] == true
        ps[uid][:membre] = true
        debug "= :membre mis à TRUE dans les data lecteur"
        modified = true
      end
      unless dlec[:follower] == false
        ps[uid][:follower] = false
        debug "= :follower mis à FALSE dans les data lecteur"
        modified = true
      end
    end
    
    ##
    ## En offline, s'il y a eu des modifications, il faut actualiser
    ## le fichier distant
    ##
    if offline? && modified
      flash "Les données des readers ont été modifiées. Il serait bon d'uploader le pstore pstore_readers.pstore APRÈS AVOIR VÉRIFIÉ LES INFORMATIONS."
    end

    ##
    ## Y a-t-il des opérations administrateur à faire
    ##
    if admin?
      # TODO:
      flash "Vous êtes reconnu comme Admin"
      debug "= TODO: Administrateur détecté (check des opérations à faire)"
    end
  end
  
end