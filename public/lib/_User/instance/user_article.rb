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
    @articles_noted ||= destore_reader( :articles_noted )
  end
  
  ##
  #
  # Ajoute un article noté par l'user (quel qu'il soit)
  #
  def add_article_noted art_id
    return unless trustable?
    @articles_noted = destore_reader(:articles_noted)
    @articles_noted << art_id
    store_reader :articles_noted => @articles_noted
  end
  
  ##
  #
  # @Return TRUE si l'user peut voter pour l'article d'ID +art_id+
  #
  def can_note_article? art_id
    return false unless trustable?
    return false == articles_noted.include?(art_id)
  end
  
  ##
  #
  # @return TRUE si l'user peut voter pour les articles EN PROJET
  #
  #
  def can_vote_articles?
    return false unless trustable?
    return last_time_vote.nil? || (last_time_vote < (Time.now.to_i - 60.days))
  end
  
  ##
  #
  # Retourne la date de dernier vote
  #
  def last_time_vote
    @last_time_vote ||= destore_reader(:last_vote)
  end
  
  ##
  #
  # Définit la dernière date de vote du reader
  #
  def set_last_time_vote
    store_reader :last_vote => Time.now.to_i
  end
  
end