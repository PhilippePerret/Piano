# encoding: UTF-8
=begin

Méthodes d'instance User gérant son interaction avec les articles

=end
class User
  
  ##
  #
  # = main =
  #
  # Méthode appelée à chaque chargement d'un article, pour
  # le mémoriser et déterminer peut-être sa durée de lecteur
  #
  def add_connexion_article
    a = app.article
    
    ##
    ## On récupère les valeurs courantes
    ##
    d = destore( articles: {}, current_article: nil )
    last_article  = d[:current_article] 
    data_articles = d[:articles]
    
    ##
    ## Si un précédent article était lu, on
    ## enregistre sa fin de lecture et on l'ajoute
    ## à la liste des articles
    ##
    unless last_article === nil
      last_article[:end]    = Time.now.to_i
      last_article[:duree]  = last_article[:end] - last_article[:start]
      ##
      ## Peut-être l'article a été déjà lu au cours de
      ## cette session (ça arrive pour plein de page). Dans ce
      ## cas, on enregistre juste sa duree et sa date de fin
      ##
      astored = if data_articles.has_key? last_article[:id]
        astored = data_articles[last_article[:id]]
        astored[:end]     = Time.now.to_i
        astored[:duree]   += last_article[:duree]
        astored.merge! :discontinous => true
      else
        last_article
      end
      data_articles.merge! last_article[:id] => astored
      debug "= Lecture complète article enregistrée : #{astored.inspect}"
    end
    
    store(
      articles:         data_articles,
      current_article:  { id: a.id, start: Time.now.to_i, end: nil, duree: nil, discontinous: false }
    )
  end
  
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