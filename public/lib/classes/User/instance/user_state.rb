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
      @is_identified || remote_ip != nil
    end
  end
  
  ##
  #
  # Retourne TRUE si l'user est un membre
  #
  def membre?
    return false if false == trustable? || id.nil?
    PStore::new(self.class.pstore).transaction do |ps|
      ps.fetch(id, nil) != nil
    end
  end
  
  ##
  #
  # Return TRUE si l'user est un follower
  #
  def follower?
    return false if false == trustable? || @mail.nil?
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
  # Return TRUE si l'user est un membre-administrateur
  #
  def admin?
    @is_admin = ( identified? && membre? && grade == :creator ) if @is_admin === nil
    @is_admin
  end
  
end