# encoding: UTF-8
=begin

Méthodes d'instances User utilitaires

=end
class User
  
  ##
  #
  # Enregistre la date de dernière connexion (login)
  #
  # Elle est enregistrée dans les data lecteur, pas dans les
  # data du membre, donc elle est utilisable pour tout user
  # quel qu'il soit.
  #
  def set_last_connexion
    set_as_lecteur :last_connexion => Time.now.to_i
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
  # NOTES IMPORTANTES :
  #
  #   * Il faut absolument utiliser saved_uid dans la méthode, car
  #     uid risquerait d'essayer d'atteindre les pstores ouverts ici
  #
  def check_as_membre
    saved_uid = get(:uid)
    if saved_uid.nil?
      saved_uid = uid # pour lui en donner un
      set :uid => saved_uid
      debug "= Propriété :uid réglée dans les data du membre (#{saved_uid})"
    end
    
    if offline?
      fichier_pointeurs = Fichier::new(app.pstore_pointeurs_lecteurs)
      fichier_pointeurs.download
      debug "= Fichier des pointeurs lecteurs downloadé en local"
    end
    modified = false
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps| ps.abort end
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      checked_mail = ps.fetch(mail, nil)
      if checked_mail.nil? || checked_mail != saved_uid
        ps[mail] = saved_uid
        debug "= Pointeur lecteur mail -> uid ajouté (#{mail} -> #{saved_uid})"
        modified = true
      end
      # Note: pour la remote_ip, il ne faut pas faire comme avec le
      # mail car l'utilisateur peut avoir plusieur remote_ip
      if ps.fetch(remote_ip, nil).nil?
        ps[remote_ip] = saved_uid
        debug "= Pointeur lecteur remote_ip -> uid ajouté (#{remote_ip} -> #{saved_uid})"
        modified = true
      end
      # Note : le session-id sera ajouté ou a été ajouté autrement
    end
    if offline? && modified
      fichier_pointeurs.upload
      debug "= Fichier des pointeurs lecteurs uploadé sur le serveur distant"
    end

    ##
    ## Les informations lecteur du membre sont-elles
    ## valides ?
    ##
    if offline?
      fichier = Fichier::new app.pstore_lecteurs
      fichier.download
      debug "= Fichier distant des data lecteurs downloadé"
    end
    modified = false
    PStore::new(app.pstore_lecteurs).transaction do |ps| ps.abort end
    PStore::new(app.pstore_lecteurs).transaction do |ps|
      dlec = ps[saved_uid]
      unless dlec[:type] == :membre
        ps[saved_uid][:type] = :membre
        debug "= :type du membre mis à :membre dans les data lecteur"
        modified = true
      end
      unless dlec[:id] == id
        ps[saved_uid][:id] = id
        debug "= :id du membre mis à #{id} dans les data lecteur"
        modified = true
      end
      unless dlec[:membre] == true
        ps[saved_uid][:membre] = true
        debug "= :membre mis à TRUE dans les data lecteur"
        modified = true
      end
      unless dlec[:follower] == false
        ps[saved_uid][:follower] = false
        debug "= :follower mis à FALSE dans les data lecteur"
        modified = true
      end
    end
    if offline? && modified
      fichier.upload
      debug "= Fichier local des data-lecteurs uploadé sur le serveur distant"
    end

    ##
    ## Y a-t-il des opérations administrateur à faire
    ##
    if admin?
      debug "= Administrateur détecté (check des opérations à faire)"
    end
  end
  
end