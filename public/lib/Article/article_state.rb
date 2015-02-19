# encoding: UTF-8
=begin

Méthodes d'instance pour l'état de l'article
(pour savoir si c'est une table des matières, s'il est en projet, etc.)

=end
class App
  class Article
    
    def exist?
      File.exist? fullpath
    end
    
    ##
    #
    # @return TRUE si c'est un article administrateur
    #
    #
    def article_admin?
      @is_article_admin = idpath.start_with?("admin/") if @is_article_admin === nil
      @is_article_admin
    end
    
    ##
    #
    # @return TRUE si l'article est achevé
    #
    def complete?
      @is_complete = get(:etat) == 9 if @is_complete === nil
      @is_complete
    end
    
    def tdm?
      @is_tdm ||= ( name == '_tdm_.erb' )
    end
    
    def en_projet?
      @en_projet = get(:etat) == 1 if @en_projet === nil
      @en_projet
    end
    
    
  end
end