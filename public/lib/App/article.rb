# encoding: UTF-8
=begin

Méthode d'instance gérant les articles

=end
class App
  
  ##
  #
  # Instance App::Article de l'article courant
  #
  #
  def article
    @article ||= App::Article::new(cgi["article"] || cgi["a"])
  end    
    
  ##
  #
  # ID-Path de l'article courant (raccourci)
  #
  def current_article
    @current_article ||= article.idpath
  end
  
  def img_a_venir
    @img_a_venir ||= "<img class='avenir' src='./public/page/img/a_venir.png' />"
  end
  
  # ---------------------------------------------------------------------
  #
  #   App::Article
  #
  # ---------------------------------------------------------------------
  class Article
    
    ##
    ## Raccourcis pour atteindre des articles courants
    ##
    ## À utiliser avec la méthode d'helper `link_to'. Par exemple :
    ## <%= link_to :home %>
    ##
    SHORTCUTS = {
      :home           => {titre: "Accueil", relpath: 'main/home'},
      :mailing        => {titre: "s'inscrire sur le mailing-list", relpath: 'main/rester_informed'},
      :vote_articles  => {titre: "Choisissez l'ordre des prochains articles", relpath: 'main/articles_vote'}
    }
    
    ##
    ## États que peut avoir l'article
    ##
    ETATS = {
      0 => {hname: "Indéfini",      value: 0},
      1 => {hname: "En projet",     value: 1},
      2 => {hname: "Projet",        value: 2},
      7 => {hname: "Rédaction",     value: 7},
      8 => {hname: "Finalisation",  value: 8},
      9 => {hname: "Achevé",        value: 9}
    }
    
    # ---------------------------------------------------------------------
    #
    #   Classe App::Article
    #
    # ---------------------------------------------------------------------
    class << self
      
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
      def tdm_with arr_titres
        c = "<ul class='tdm'>"
        c << arr_titres.collect do |dtitre|
          titre, artname, a_venir = dtitre
          '<li>' + app.link_to( titre, File.join(app.article.folder, artname) ) + (a_venir ? app.img_a_venir : '') + '</li>'
        end.join("")
        c << "</ul>"
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
      # Pstore des données des articles
      #
      def pstore
        @pstore ||= File.join('.', 'data', 'pstore', 'articles.pstore')
      end
      
      ##
      #
      # PStore contenant la table de correspondance entre l'idpath et
      # l'ID absolu de l'article
      #
      def pstore_idpath_to_id
        @pstore_idpath_to_id ||= File.join('.', 'data', 'pstore', 'articles_idpath_to_id.pstore')
      end
      
    end
    # ---------------------------------------------------------------------
    #
    #   Instance App::Article
    #
    # ---------------------------------------------------------------------
    
    ##
    ## Path fournie en argument
    ##
    attr_reader :path_init
    
    ##
    ## Contenu confectionné de l'article
    ##
    attr_reader :content
    
    ##
    #
    # Instanciation
    #
    # +anypath+ peut être :
    #     * L'ID absolu de l'article
    #     * Une path quelconque, se terminant par "/" pour
    #       une table des matières, sans ".erb" ou avec, etc.
    #
    def initialize anypath
      case anypath
      when Fixnum   then @id = anypath
      else @path_init = anypath
      end
    end
    
    ##
    #
    # Retourne la valeur de la propriété +key+
    #
    #
    def get key
      PStore::new(App::Article::pstore).transaction do |ps|
        ps[id][key]
      end
    end
    
    
    ##
    #
    # Méthode principal, appelée par la vue `content.erb', qui définit
    # le code de l'article et le place dans @content
    #
    def load
      ##
      ## Confection du contenu de l'article
      ##
      @content = app.view( "article/#{base}" )
      ##
      ## On ajoute un chargement de cet article
      ##
      add_lecture
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
        titre:          "",       # Titre entré manuellement
        x:              0,        # Nombre de chargements
        duree_lecture:  0,        # Durée totale de lecture
        etat:           0,        # État de l'article (cf. ETATS)
        votes:          0,        # Valeur de vote pour cet article
        updated_at:     Time.now.to_i,
        created_at:     Time.now.to_i
      }
    end
    
    ##
    #
    # ID absolu de l'article (dans la table de correspondance idpath<->id)
    #
    # Si l'ID n'est pas encore défini, un nouvel id est défini et
    # ajouté à la table de correspondance des idpath<->id
    #
    def id
      @id ||= begin
        id = nil
        PStore::new(App::Article::pstore_idpath_to_id).transaction do |ps|
          id = ps.fetch( idpath, nil )
          if id.nil?
            # Cet article n'a pas encore été consigné
            id = ps.fetch(:last_id, 0) + 1
            ps[:last_id] = id
            ps[id]      = idpath
            ps[idpath]  = id
          end
        end
        id
      end
    end
    ##
    #
    # Identifiant path de l'article
    #
    # C'est le chemin relatif dans ./public/page/article, sans l'extension
    # Par exemple : 'theme/contre/lire_en_jouant'
    #
    def idpath
      @idpath ||= begin
        if @id.nil?
          # => Article instancié par son path
          rp = path_init.to_s.sub(/\.erb$/,'')
          if rp.to_s == ""        then rp = "main/home"
          elsif rp.end_with? "/"  then rp.concat("_tdm_")
          end
          rp
        else
          # => Article instancié par son ID
          PStore::new(App::Article::pstore_idpath_to_id).transaction do |ps|
            ps[id]
          end
        end
      end
    end
    
    ##
    #
    # Méthode appelée par les fichier `_body_.erb' des dossiers d'article
    # retournant le code de l'article précisément demandé.
    #
    def view
      app.view "article/#{folder}/#{name}"
    end
    
    
    ##
    #
    # @return le path relatif du fichier ERB principal à afficher dans le
    # dossier ./public/page/article/
    #
    # Pour un article du dossier 'main', on retourne l'article lui-même
    # Sinon, on retourne le fichier _body_.erb qui doit charger l'article.
    #
    def base
      if folder == "main"
        "#{relpath}"
      else
        "#{folder}/_body_.erb"
      end
    end
    
    ##
    #
    # Chemin relatif à l'article
    #
    def relpath
      @relpath ||= "#{idpath}.erb"
    end
    
    ##
    #
    # Retourne le chemin complet à l'article demandé
    # Utilisé seulement pour l'édition de l'article (dans les autres cas,
    # c'est le fichier _body_.erb qui est chargé et qui charge l'article)
    #
    def fullpath
      @fullpath ||= File.expand_path(File.join('.','public','page','article',folder, name))
    end
    
    ##
    #
    # Nom du fichier de l'article
    #
    def name
      @name ||= File.basename(relpath)
    end
    
    ##
    #
    # @return le dossier (nom) de l'article
    #
    def folder
      @folder ||= File.dirname(relpath)
    end
  
    # ---------------------------------------------------------------------
    #   Lectures
    # ---------------------------------------------------------------------
    
    ##
    #
    # Ajoute une lecture de l'article courant
    #
    #
    def add_lecture
      PStore::new(App::Article::pstore).transaction do |ps|
        ps[id] = default_data unless ps.roots.include? id
        ps[id][:x] += 1
        ps[id][:updated_at] = Time.now.to_i
      end
    end
    
    ##
    #
    # Ajoute une durée de lecture de l'article
    #
    #
    def add_duree_lecture duree
      PStore::new(App::Article::pstore).transaction do |ps|
        ps[id][:duree_lecture] += duree
        ps[id][:updated_at] = Time.now.to_i
        @hduree_lecture = ps[id][:duree_lecture]
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
    
    # ---------------------------------------------------------------------
    #
    #   Helpers méthodes
    #
    # ---------------------------------------------------------------------
    def as_li options = nil
      options ||= {}
      tit = get(:titre)
      tit = idpath if tit.to_s == ""
      (
        tit +
        (options[:votes] ? "cote: #{get :votes}" : '')
      ).in_li('data-id' => id)
    end
    
  end # / App::Article
end