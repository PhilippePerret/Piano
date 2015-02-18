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
        ps[id] = default_data if ps.fetch(id, nil).nil?
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