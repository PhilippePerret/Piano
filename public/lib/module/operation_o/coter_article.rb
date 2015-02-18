# encoding: UTF-8
class App
  class Operation
    class << self      
             
      ##
      #
      # Pour coter l'article
      #
      #
      def coter_article
        raise "Pirate !" unless cu.trustable?

        ##
        ## L'article visé par la cote
        ##
        art = App::Article::get(param('article_id').to_i)
        raise "Pirate !" if art.nil? || art.idpath != param('article')
        
        app.require_module 'article/coter_article'
        art.coter_article
        
      end
    end
  end
end