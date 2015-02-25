# encoding: UTF-8
=begin

Toutes les méthodes d'instance de l'article gérant les lectures

=end
class App
  class Article
    
    
    ##
    #
    # Définit des valeurs de l'article dans le pstore
    #
    def set hdata
      hdata.merge! :updated_at => Time.now.to_i
      PPStore::new(self.class.pstore).transaction do |ps|
        hdata.each { |prop, val| ps[id][prop] = val }
      end
      # ppstore self.class.pstore, id => hdata
      hdata.each { |k, v| self.instance_variable_set("@#{k}", v) }
    end
    
    ##
    #
    # Retourne la valeur de la propriété +key+
    #
    def get key
      data.nil? ? nil : data[key]
    end
    
    # ---------------------------------------------------------------------
    #   Les données
    # ---------------------------------------------------------------------
    
    ##
    # ID absolu de l'article
    #
    # (dans la table de correspondance idpath<->id)
    #
    def id;     @id ||= get_id_in_table_or_create end
    
    ##
    # Identifiant path de l'article
    #
    # C'est le chemin relatif dans ./public/page/article, sans l'extension
    # Par exemple : 'theme/contre/lire_en_jouant'
    #
    def idpath;      @idpath ||= define_idpath end
    
    ##
    #
    # Titre de l'article
    #
    def titre;      @titre ||= ( get(:titre) || titre_in_file ) end    
    
    ##
    #
    # Retourne toutes les données pstore de l'article
    #
    def data
      @data ||= ppdestore( self.class.pstore, id )
    end
    

    # ---------------------------------------------------------------------
    #   Lectures
    # ---------------------------------------------------------------------

    ##
    #
    # Ajoute un nombre de connexion à l'article
    #
    # Note : Cron-job
    #
    def add_connexions nombre_connexion
      check_existence_article_data
      set :x => ( get( :x ) + nombre_connexion )
    end
    
    ##
    #
    # Ajoute un nombre de secondes à la durée de
    # lecture de l'article
    #
    # Note : Cron-job
    #
    def add_duree nombre_secondes
      check_existence_article_data
      set :duree_lecture => ( get(:duree_lecture) + nombre_secondes )
    end
    
    
    ##
    #
    # Data par défaut
    #
    #
    def default_data
      @default_data ||= {
        id:             @id,
        idpath:         idpath,
        titre:          titre_in_file,       
        x:              0,        # Nombre de chargements
        duree_lecture:  0,        # Durée totale de lecture
        etat:           0,        # État de l'article (cf. ETATS)
        votes:          0,        # Valeur de vote pour cet article
        updated_at:     Time.now.to_i,
        created_at:     Time.now.to_i
      }
    end
    
  end # Article
end # App