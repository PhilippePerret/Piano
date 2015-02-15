# encoding: UTF-8
=begin

Méthodes de class de la classe App::Article

=end
class App
  class Article
    
    # ---------------------------------------------------------------------
    #
    #   Classe App::Article
    #
    # ---------------------------------------------------------------------
    class << self
      
      ##
      ## {Hash} des instances d'articles déjà instanciées
      ##
      attr_reader :instances
      
      ##
      #
      # @Return l'instance App::Article de l'article défini par
      # son ID ou son idpath +fooid+
      #
      def get fooid
        @instances ||= {}
        unless @instances.has_key? fooid
          art = App::Article::new fooid
          @instances.merge!(
            art.id      => art,
            art.idpath  => art
          )
        end
        @instances[fooid]
      end
      
      ##
      #
      # Boucle sur tous les articles
      #
      #
      def each filtre = nil
        sort_by_votes = filtre.delete(:sort_by_votes)
        listarts = articles.dup
        if sort_by_votes
          listarts = listarts.sort_by{ |k,v| v.get(:votes) }.reverse
        end
        listarts.each do |art_id, art|
          ok = true
          filtre.each do |prop, value|
            if art.get(prop) != value
              ok = false
              break
            end
          end
          next unless ok
          yield art
        end
      end
      
      ##
      #
      # Tous les articles
      #
      #
      def articles
        @articles ||= begin
          h = {}
          PStore::new(pstore).transaction do |ps|
            keys = ps.roots.dup
            keys.delete(:last_id)
            keys.each { |key| h.merge! key => new(key) }
          end
          h
        end
      end
      
      ##
      #
      # Retourne le path complet de l'article de chemin relatif +rp+
      #
      def path_to rp
        File.join(folder, rp)
      end
      
      ##
      #
      # @return le code HTML de la table des matière avec les titres
      # d'articles définis dans +arr_titres+
      #
      # Ajoute aussi un lien pour voter pour l'ordre des articles en
      # projet.
      #
      def tdm_with arr_titres
        c = "<ul class='tdm'>"
        c << arr_titres.collect do |dtitre|
          titre, artname, a_venir = dtitre
          '<li>' + app.link_to( titre, File.join(app.article.folder, artname) ) + (a_venir ? app.img_a_venir : '') + '</li>'
        end.join("")
        c << "</ul>"
        ##
        ## Lien article en projet
        ##
        c << link_to(:vote_articles).in_div(class: 'right air')
        return c
      end
      
      ##
      #
      # Dossier contenant tous les articles
      #
      #
      def folder
        @folder ||= File.join('.', 'public', 'page', 'article')
      end
      
      
      ##
      #
      # PStore pour les cotes des articles
      #
      #
      def pstore_cotes
        @pstore_cotes ||= File.join(app.folder_pstore, 'articles_cotes.pstore')
      end
      
      ##
      #
      # Pstore pour les votes
      #
      #
      def pstore_votes
        @pstore_votes ||= File.join(app.folder_pstore, 'votes_articles.pstore')
      end
      
      ##
      #
      # Pstore des données des articles
      #
      def pstore
        @pstore ||= File.join(app.folder_pstore, 'articles.pstore')
      end
      
      ##
      #
      # PStore des commentaires des articles
      #
      def pstore_comments
        @pstore_comments ||= File.join(app.folder_pstore, 'articles_comments.pstore')
      end
      ##
      #
      # PStore contenant la table de correspondance entre l'idpath et
      # l'ID absolu de l'article
      #
      def pstore_idpath_to_id
        @pstore_idpath_to_id ||= File.join('.', 'data', 'pstore', 'articles_idpath_to_id.pstore')
      end
      
    end # << self App::Article
    
  end # Article
end # App