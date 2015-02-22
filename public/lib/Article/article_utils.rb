# encoding: UTF-8
class App
  class Article
    
    ##
    #
    # Méthode qui détruit les données de l'article dans le pstore
    #
    def remove_data
      raise "Pirate !" unless offline?
      ppstore_remove( self.class.pstore, id )
    end
    
    
    ##
    #
    # Si les données de l'article n'existent pas, on les
    # crée
    #
    def check_existence_article_data
      if ppdestore(self.class.pstore, @id).nil?
        # raise "SITE EN D&Eacute;BUGGAGE PENDANT UNE HEURE. Merci de votre patience."
        ppstore(self.class.pstore, @id => default_data)
      end
    end
    
    
    ##
    #
    # Cherche l'ID dans la table de correspondance entre IDPATH et
    # ID. Crée un nouvel ID et un nouvel article si l'idpath n'est
    # pas trouvé.
    #
    def get_id_in_table_or_create
      @id = ppdestore self.class.pstore_idpath_to_id, idpath
      if @id.nil?
        ##
        ## Un article qui n'a pas encore été consigné
        ##
        PPStore::new(self.class.pstore_idpath_to_id).transaction do |ps|
          @id = ps.fetch(:last_id, 0) + 1
          ps[:last_id]  = @id
          ps[@id]       = idpath
          ps[idpath]    = @id
        end
      end
      ##
      ## Force la création des données de l'article si nécessaire.
      ## Note : On ne fait pas ça dans la transaction précédente parce
      ## qu'il peut arriver par erreur que l'ID soit défini et pas les
      ## données de l'article…
      ##
      check_existence_article_data
      
      return @id
    end
    
    
    ##
    #
    # Retourne le titre de l'article dans le fichier
    #
    #
    def titre_in_file
      if File.exist? fullpath
        titre_in_code File.read(fullpath).force_encoding('utf-8')
      else
        debug "= Fichier ID #{id} introuvable (#{fullpath}). Impossible de récupérer son titre"
        ""
      end
    end
    
    ##
    # Cherche le titre de l'article dans le +code+ fourni
    #
    def titre_in_code code
      if idpath == "main/home"
        "Accueil du site"
      elsif name == "_tdm_.erb"
        "Table des matières (#{idpath})"
      elsif code.match(/<h2>(.*?)<\/h2>/)
        code.match(/<h2>(.*?)<\/h2>/).to_a[1].to_s.strip
      elsif code.index('article.body_content')
        code.match(/article\.body_content(.*?)"(.*?)"/).to_a[1].to_s.strip
      else
        debug "= Titre introuvable dans le fichier existant #{fullpath}"
        ""
      end
    end
    
  end
end