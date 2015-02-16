# encoding: UTF-8
=begin

Méthodes d'instance User gérant son interaction avec les articles

=end
class User
  
  ##
  #
  # Retourne la liste des ID des articles déjà notés par
  # l'user
  #
  def articles_noted
    @articles_noted ||= begin
      PStore::new(app.pstore_lecteurs).transaction do |ps|
        ps[uid][:articles_noted]
      end
    end
  end
  
  ##
  #
  # Ajoute un article noté par l'user (quel qu'il soit)
  #
  def add_article_noted art_id
    PStore::new(app.pstore_lecteurs).transaction do |ps|
      ps[uid][:articles_noted] << art_id
      @articles_noted = ps[uid][:articles_noted]
    end
  end
  
  ##
  #
  # @Return TRUE si l'user peut voter pour l'article d'ID +art_id+
  #
  def can_note_article? art_id
    return true
    return false unless trustable?
    return false == articles_noted.include?(art_id)
  end
  
  ##
  #
  # @return TRUE si l'user peut voter pour les articles EN PROJET
  #
  #
  def can_vote_articles?
    return true
    return false unless trustable?
    return last_time_vote.nil? || (last_time_vote < (Time.now.to_i - 60.days))
  end
  
  def last_time_vote
    @last_time_vote ||= begin
      data_as_lecteur[:last_vote]
    end
  end
  
end