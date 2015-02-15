# encoding: UTF-8
class User

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'état
  #
  # ---------------------------------------------------------------------
 
  ##
  #
  # Return TRUE si l'user courant est "trustable", c'est-à-dire
  # s'il peut effectuer des votes, mettre des commentaires, etc.
  #
  # Pour qu'il soit trustable, il faut soit qu'il soit identifié,
  # donc qu'il soit membre accepté, soit qu'il ait une remote address
  #
  def trustable?
    @is_trustable ||= begin
      @is_identified || app.cgi.remote_addr != nil
    end
  end
  
  ##
  #
  # Retourne TRUE si l'user est un membre
  #
  def membre?
    return false unless trustable?
    PStore::new(self.class.pstore).transaction do |ps|
      ps.fetch(id, nil) != nil
    end
  end
  
  ##
  #
  # Return TRUE si l'user est un follower
  #
  def follower?
    return false unless trustable?
    PStore::new(app.pstore_followers).transaction do |ps|
      ps.roots.include? mail
    end
  end
  
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
  
end