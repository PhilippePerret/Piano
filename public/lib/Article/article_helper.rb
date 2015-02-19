# encoding: UTF-8
class App
  class Article
            
    ##
    #
    # Durée de lecture en format humain
    #
    #
    def hduree_lecture
      @hduree_lecture ||= get(:duree_lecture).as_horloge
    end
    
  end
end