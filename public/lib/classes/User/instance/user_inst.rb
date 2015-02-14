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
  #   Méthodes d'état
  #
  # ---------------------------------------------------------------------
 
  ##
  #
  # Return TRUE si le membre est identifié
  #
  #
  def identified?
    @is_identified == true
  end
  
  ##
  #
  # @return TRUE si l'user peut voter pour les articles
  #
  #
  def can_vote_articles?
    last_time_vote = PStore::new(App::Article::pstore_votes).transaction do |ps|
      ps.fetch(remote_ip, nil)
    end
    return last_time_vote.nil? || (last_time_vote < (Time.now.to_i - 60.days))
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
  def login
    User::current = self
    set :session_id => app.session.id
    app.session['user_id']  = id
    @is_identified          = true
    flash "Bienvenue, #{pseudo} !"
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