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
      remove_old_courantes
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
    #
    def add
      add_in_all
      add_duree_lecture if last_courante
      add_courante
    end
    
    ##
    # Ajout de cet connexion à toutes les connexions
    #
    def add_in_all
      PStore::new(pstore_all).transaction do |ps|
        ps[:nombre_connexions] = ps.fetch(:nombre_connexions, 0) + 1
        ps[:times] = [] if ps.fetch(:times, nil).nil?
        ps[:times] << Time.now.to_i
      end
    end
    
    ##
    #
    # Méthode qui ajoute la connexion courante aux connexions courantes
    #
    #
    def add_courante
      now = Time.now.to_i
      PStore::new(pstore_courantes).transaction do |ps|
        ps[app.session.id] = {
          session_id:   app.session.id, 
          time:         now, 
          article:      app.article.id, 
          ip:           cu.remote_ip 
        }
      end
    end
    
    ##
    #
    # Article chargé au cours de la précédente connexion
    #
    #
    def last_article
      @last_article ||= begin
        App::Article::new last_courante[:article].to_i
      end
    end
    
    ##
    #
    # Retourne la dernière connexion associée à la session courante
    #
    #
    def last_courante
      @last_courante ||= begin
        PStore::new(pstore_courantes).transaction do |ps|
          ps.fetch(app.session.id, nil)
        end
      end
    end
    
    ##
    #
    # Méthode qui enregistre la durée de lecture de l'article
    # précédent. 
    #
    #
    def add_duree_lecture
      return if last_courante.nil?
      duree_lecture = Time.now.to_i - last_courante[:time]
      last_article.add_duree_lecture duree_lecture
    end
    
    ##
    #
    # Méthode qui profite de la connexion pour supprimer les connexions
    # courantes qui sont "mortes".
    #
    # NOTES
    #
    #   * En profite aussi pour définir le nombre de connectés courants
    #   * En profite pour marquer la fin de la lecture des articles
    #
    def remove_old_courantes
      now = Time.now.to_i
      uneheure = now - 3600
      PStore::new(pstore_courantes).transaction do |ps|
        ps.roots.dup.each do |key|
          if ps[key][:time] < uneheure
            
            ##
            ## On ajoute une durée moyenne au dernier article chargé
            ##
            art = App::Article::new( ps[key][:article].to_i )
            art.add_duree_lecture 5 * 60
            
            ##
            ## On détruit cette connexion
            ##
            ps.delete(key)
            
          end
        end
        ##
        ## Le nombre actuel de connectés
        ##
        @count = ps.roots.count
      end
    end
    
    ##
    #
    # Pstore de toutes les connexions
    #
    def pstore_all
      @pstore_all ||= File.join('.', 'data', 'pstore', 'connexions.pstore')
    end
    
    ##
    #
    # Pstore des connexions courantes (en activité)
    #
    #
    def pstore_courantes
      @pstore_courantes ||= File.join('.', 'data', 'pstore', 'connexions_courantes.pstore')
    end
  end
  
end