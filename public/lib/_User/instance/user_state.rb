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
    if @is_trustable === nil
      @is_trustable = @is_identified || ENV['REMOTE_ADDR'].to_s != ""
    end
    @is_trustable
  end
  
  ##
  #
  # Retourne TRUE si l'user est un membre
  #
  def membre?
    return false if false == @is_trustable || id.nil?
    @is_membre ||= ( ppdestore( self.class.pstore, id ) != nil )
  end
  
  ##
  #
  # Return TRUE si l'user est un follower
  # Cf. N0002
  #
  def follower?
    return false if false == @is_trustable
    if @is_follower === nil
      if @mail.nil?
        # Cf. N0002
        @is_follower = destore(:user_type) == :follower
      else
        @is_follower = ppdestore(app.pstore_followers, mail) != nil
      end
    end
    @is_follower
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
    @is_admin = ( @is_identified && membre? && grade == :creator ) if @is_admin === nil
    @is_admin
  end
  
  ##
  # Return TRUE si le membre peut soumettre un sujet
  def can_submit_subject?
    return false unless cu.membre?
    return (grade_as_level & User::LEVEL_SUGGEST_IDEAS) > 0
  end
  
end