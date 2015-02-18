# encoding: UTF-8
=begin

Méthodes utiles au cron job pour enregistrer des données
dans les articles lus la veille.

=end
class Article
  
  ##
  #
  # Ajoute un certain nombre de lectures de l'article
  #
  # La méthode est utilisée lorsque le cron rassemble les
  # informations sur les articles lus la veille.
  #
  #
  def add_lectures nombre
    return if article_admin?
    check_existence_article_data
    set :x => nombre
  end
  
  ##
  #
  # Ajoute une durée de lecture de l'article
  #
  # Note: Utilisé par le cron job quotidiennement
  #
  def add_duree_lecture duree_added
    return if article_admin?
    check_existence_article_data
    duree = get(:duree_lecture) || 0
    set :duree_lecture => ( duree + duree_added )
  end
  
end