# encoding: UTF-8
=begin

Toutes les méthodes d'instance de l'article gérant les lectures

=end
class App
  class Article
    
  
    # ---------------------------------------------------------------------
    #   Lectures
    # ---------------------------------------------------------------------
    
    def check_existence_article_data
      PStore::new(self.class.pstore).transaction do |ps|
        ps[id] = default_data if ps.fetch( id, nil).nil?
      end
    end
    
    ##
    #
    # Ajoute une lecture de l'article courant
    #
    #
    def add_lecture
      check_existence_article_data
      PStore::new(self.class.pstore).transaction do |ps|
        ps[id][:x] += 1
        ps[id][:updated_at] = Time.now.to_i
      end
    end
    
    ##
    #
    # Ajoute une durée de lecture de l'article
    #
    #
    def add_duree_lecture duree
      check_existence_article_data
      PStore::new(App::Article::pstore).transaction do |ps|
        ps[id][:duree_lecture] += duree
        ps[id][:updated_at] = Time.now.to_i
        @hduree_lecture = ps[id][:duree_lecture]
      end
    end
    
    ##
    #
    # Durée de lecture en format humain
    #
    #
    def hduree_lecture
      @hduree_lecture ||= get(:duree_lecture).as_horloge
    end
    
  end # Article
end # App