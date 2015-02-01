# encoding: UTF-8
=begin

Méthodes d'instance gérant le suivi des connexions.

=end
class App

  ##
  #
  # Méthode principale qui ajoute une connexion à un article
  #
  #
  def new_connexion
    PStore::new(pstore_connexions).transaction do |ps|
      ps[:nombre_connexions] = ps.fetch(:nombre_connexions, 0) + 1
      cons = ps.fetch(relpath_article, {article: relpath_article, nombre: 0, times: []})
      cons[:nombre] += 1
      cons[:times] << Time.now.to_i
      ps[relpath_article] = cons
    end
  end
  
end