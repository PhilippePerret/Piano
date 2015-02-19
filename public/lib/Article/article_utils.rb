# encoding: UTF-8
class App
  class Article
    
    ##
    #
    # Méthode qui détruit les données de l'article dans le pstore
    #
    def remove_data
      raise "Pirate !" unless offline?
      removed = false
      PStore::new(App::Article::pstore).transaction do |ps|
        ps.delete id
        removed = ps.fetch(id,nil) === nil
      end
      return removed
    end
    
    
    ##
    #
    # Si les données de l'article n'existent pas, on les
    # crée
    #
    def check_existence_article_data
      PStore::new(self.class.pstore).transaction do |ps|
        ps[id] = default_data if ps.fetch(id, nil).nil?
      end
    end
    
    
    ##
    #
    # Cherche l'ID dans la table de correspondance entre IDPATH et
    # ID. Crée un nouvel ID et un nouvel article si l'idpath n'est
    # pas trouvé.
    #
    def get_id_in_table_or_create
      id = nil
      PStore::new(App::Article::pstore_idpath_to_id).transaction do |ps|
        id = ps.fetch( idpath, nil )
        return id unless id.nil?

        # Cet article n'a pas encore été consigné
        id = ps.fetch(:last_id, 0) + 1
        ps[:last_id] = id
        ps[id]      = idpath
        ps[idpath]  = id
      end

      @id = id

      ##
      ## Force la création des données de l'article
      ##
      check_existence_article_data

      return id
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