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
    check_as_membre
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
      fichier = Fichier::new(app.pstore_pointeurs_lecteurs)
      fichier.download
      debug "= Fichier des pointeurs lecteurs downloadé en local"
    end
    modified = false
    # sleep 4
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps| ps.abort end
    PStore::new(app.pstore_pointeurs_lecteurs).transaction do |ps|
      checked_mail = ps.fetch(mail, nil)
      if checked_mail.nil? || checked_mail != mail
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
      fichier.upload
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

    # ##
    # ## Y a-t-il des opérations administrateur à faire
    # ##
    # if admin?
    #   debug "= Administrateur détecté (check des opérations à faire)"
    # end
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