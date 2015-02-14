# encoding: UTF-8
=begin

Méthode d'instance gérant les articles

=end
class RedirectError < StandardError; end

class App
  class Article
    ##
    ## Raccourcis pour atteindre des articles courants
    ##
    ## À utiliser avec la méthode d'helper `link_to'. Par exemple :
    ## <%= link_to :home %>
    ##
    SHORTCUTS = {
      :home               => {titre: "Accueil", relpath: 'main/home'},
      :login              => {titre: "S'identifier", relpath: 'user/login'},
      :profil             => {titre: "Votre profil", relpath: 'user/profil'},
      :edit_profil        => {titre: "Édition de votre profil", relpath: 'user/edit_profil'},
      :mailing            => {titre: "S'inscrire dans le mailing-list", relpath: 'main/rester_informed'},
      :vote_articles      => {titre: "Choisissez l'ordre des prochains articles", relpath: 'main/articles_vote'},
      :articles_en_projet => {titre: "Voir la liste des articles en projet", relpath: 'main/articles'}
    }
  end
  
  ##
  #
  # Instance App::Article de l'article courant
  #
  #
  def article
    @article ||= begin
      art = param('article')
      art = param('a') if art.to_s == ""
      App::Article::new(art)
    end
  end
  def article= pathart
    @article = App::Article::new(pathart)
    @current_article = nil
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
    ## États que peut avoir l'article
    ##
    ETATS = {
      0 => {hname: "Indéfini",      value: 0},
      1 => {hname: "En projet",     value: 1},
      2 => {hname: "Fonctionnel",   value: 2},
      3 => {hname: "Administration",value: 3},
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
        @pstore ||= File.join('.', 'data', 'pstore', 'articles.pstore')
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
        dart = ps.fetch(id, nil)
        unless dart.nil?
          dart[key]
        else
          nil
        end
      end
    end
    
    ##
    #
    # Retourne toutes les données pstore de l'article
    #
    def data
      @data ||= begin
        PStore::new(App::Article::pstore).transaction do |ps|
          dart = ps.fetch(id, nil)
        end
      end
    end
    
    ##
    #
    # Définit des valeurs de l'article dans le pstore
    # clé: les propriétés
    # value: Leur valeur
    #
    def set hdata
      PStore::new(App::Article::pstore).transaction do |ps|
        hdata.each do |prop, value|
          ps[id][prop] = value
          self.instance_variable_set("@#{prop}", value)
        end
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
        titre:          titre_in_file,       
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
    # Retourne le titre de l'article dans le fichier
    #
    #
    def titre_in_file
      if File.exist? fullpath
        code = File.read(fullpath).force_encoding('utf-8')
        @titre = code.match(/<h2>(.*?)<\/h2>/).to_a[1].to_s.strip
      else
        debug "= Fichier ID #{id} introuvable (#{fullpath}). Impossible de récupérer son titre"
        ""
      end
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
    # Titre de l'article
    #
    def titre
      @titre ||= ( get(:titre) || titre_in_file )
    end
    
    ##
    #
    # Méthode définissant le code du _body_.erb, appelée depuis un
    # fichier _body_.erb
    #
    #
    def body_content titre, options = nil
      c = ""
      c << app.link_to_tdm unless tdm?
      c << titre.in_h1
      c << view
      unless tdm? || en_projet?
        c << app.link_to_tdm
        c << section_comments
      end
    end
    
    def tdm?
      @is_tdm ||= name == '_tdm_.erb'
    end
    
    def en_projet?
      @en_projet = get(:etat) == 1 if @en_projet === nil
      debug "@en_projet : #{@en_projet.inspect} (etat : #{get(:etat)})"
      @en_projet
    end
    
    ##
    #
    # Méthode appelée par les fichiers `_body_.erb' des dossiers d'article
    # retournant le code de l'article précisément demandé.
    #
    def view
      begin
        app.view "article/#{folder}/#{name}"
      rescue RedirectError => e
        ##
        ## En cas de redirection par exemple
        ##
        ""
      rescue Exception => e
        raise e
      end
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
    
    ##
    #
    # @return les commentaires courants
    #
    #
    def comments
      @comments ||= begin
        PStore::new(self.class.pstore_comments).transaction do |ps|
          lescomments = ps.fetch(id, nil)
          if lescomments.nil?
            ps[id] = []
            []
          else
            lescomments
          end
        end
      end
    end
    
    ##
    #
    # Ajouter une commentaire (non validé) pour l'article
    #
    # Note : L'annonce à l'administration doit être faite ailleurs
    # car la méthode ne s'occupe que de l'ajout du commentaire dans
    # la table.
    #
    def add_comments new_comment, user_data
      data_comment = user_data.merge(id: comments.count, ok: false, c: new_comment, at: Time.now.to_i)
      PStore::new(self.class.pstore_comments).transaction do |ps|
        ps[id] << data_comment
      end
    end
    
    ##
    #
    # Validation d'un commentaire par l'administration
    #
    # Noter que comments_id correspond simplement à l'index des données
    # du commentaire dans la liste des commentaires.
    #
    def valider_comments comments_id
      PStore::new(self.class.pstore_comments).transaction do |ps|
        ps[id][comments_id][:ok] = true
      end
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
        tit.in_span(class: 'titre') +
        (options[:votes] ? "#{get :votes}" : '').in_span(class: 'cote')
      ).in_li('data-id' => id)
    end
    
    ##
    #
    # Retourne la section des commentaires
    #
    # Cette section contient le formulaire pour laisser un 
    # commentaire ainsi que tous les commentaires déjà déposés
    #
    def section_comments
      app.view('article/element/comments_form') +
      list_comments.in_fieldset(legend: "Commentaires")
    end
    def list_comments
      hc = comments.collect do |dcom|
        # next unless dcom[:ok]
        (
          (dcom[:ps] + ', le ' + dcom[:at].as_human_date).in_div(class: 'c_info') +
          dcom[:c].in_div(class: 'c_content')
        ).in_div(class: 'comment')
      end.join('')
      hc = "Soyez le premier à laisser un commentaire.".in_div(class: 'italic small') if hc == ""
      return hc
    end
    
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
    
  end # / Instance App::Article
end