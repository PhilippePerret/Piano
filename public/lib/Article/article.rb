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
      art = "main/home" if art == ""
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
      when Fixnum 
        @id = anypath
      else 
        @path_init = anypath
      end
    end
  
        
    ##
    # Définit l'idpath et le renvoie
    def define_idpath
      unless @id.nil? # ne pas utiliser id
        # => Article instancié par son ID
        ppdestore self.class.pstore_idpath_to_id, id
      else
        # => Article instancié par son path
        rp = path_init.to_s.sub(/\.erb$/,'')
        if rp.to_s == ""        then rp = "main/home"
        elsif rp.end_with? "/"  then rp.concat("_tdm_")
        end
        rp
      end
    end
    
    
    ##
    #
    # Path relatif du fichier ERB principal à afficher dans le
    # dossier ./public/page/article/
    #
    # Pour un article du dossier 'main', on retourne l'article lui-même
    # Sinon, on retourne le fichier _body_.erb qui doit charger l'article.
    #
    def base; folder == "main" ? "#{relpath}" : "#{folder}/_body_.erb" end
    
    ##
    #
    # Chemin relatif à l'article
    #
    def relpath; @relpath ||= "#{idpath}.erb" end
    
    ##
    #
    # Nom du fichier de l'article
    #
    def name; @name ||= File.basename(relpath) end
    
    ##
    #
    # Nom du dossier de l'article
    #
    def folder;   @folder ||= File.dirname(relpath) end
    
    ##
    #
    # Chemin complet à l'article
    #
    # Utilisé seulement pour l'édition de l'article (dans les autres cas,
    # c'est le fichier _body_.erb qui est chargé et qui charge l'article)
    #
    def fullpath
      @fullpath ||= File.expand_path(File.join('.','public','page','article',folder, name))
    end
    


  end # / Instance App::Article
end