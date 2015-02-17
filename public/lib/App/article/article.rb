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
    ## {Hash} de l'article suivant (if any)
    ##
    ## Le définir dans la vue à l'aide de :
    ## article.next = {path:, title:} ou 
    ## article.next = path (le bouton sera "Suivant ->")
    attr_accessor :next
    
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
        titre_in_code File.read(fullpath).force_encoding('utf-8')
      else
        debug "= Fichier ID #{id} introuvable (#{fullpath}). Impossible de récupérer son titre"
        ""
      end
    end
    
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