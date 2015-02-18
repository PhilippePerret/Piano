# encoding: UTF-8
=begin

Méthodes d'instance gérant le suivi des connexions.

=end
class App
  
  def connexions
    @connexions ||= App::Connexions::new(self)
  end
    
  # ---------------------------------------------------------------------
  #
  #   App::Connexion
  #
  # ---------------------------------------------------------------------
  class Connexions
    
    # ---------------------------------------------------------------------
    #
    #   Instance App::Connexions
    #
    #   Note: gère les connexions comme un ensemble
    #
    # ---------------------------------------------------------------------
    
    ##
    ## Application courante
    ##
    attr_reader :app
    
    ##
    ## Le nombre de connectés actuels
    ##
    ## @usage:    app.connexions.count
    ##
    attr_reader :count
    
    def initialize app
      @app = app
    end
    
    ##
    # = main =
    #
    # Ajoute la connexion à un article
    #
    # C'est la méthode principale appelée après le chargement d'un
    # article (ie sa confection). Elle produit :
    #
    #   * L'enregistrement d'une nouvelle connexion courante
    #   * La définition du temps de lecture de l'article précédent
    #     s'il existe.
    #
    # Maintenant, tout est géré dans le pstore-session de l'user
    # qui charge la page.
    #
    def add
      cu.add_connexion_article
    end    
    
    ##
    #
    # Pstore de toutes les connexions
    #
    def pstore_all
      @pstore_all ||= File.join('.', 'data', 'pstore', 'connexions.pstore')
    end
    
  end
  
end