# encoding: UTF-8
=begin

Class App::NewSujet
-------------------
Traitement des sujets soumis par des membres

Ce module sert autant à l'article qui permet de soumettre un sujet qu'à
l'article administration permettant de les gérer

=end

class NewSujetError < StandardError; end

class App
  class NewSujet
    
    LISTE_THEMES = [
      ["Donner des conseils", 'conseils'],
      ["Présenter une ou des techniques de jeu particulières", 'tech'],
      ["Expliquer un ou des points techniques", 'explitech'], 
      ["Expliquer un ou des points théoriques", 'explitheo'],
      ["Remettre les pendules à l'heure à propos d'un troll de forum…", 'pendheure']
    ]
    
    class << self
      
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes fonctionnelles
      #
      # ---------------------------------------------------------------------
      ##
      #
      # Pour effectuer une boucle sur tous les sujets
      #
      def each
        instances.each do |sid, sujet|
          yield sujet
        end
      end
      
      ##
      #
      # Retourne tous les sujets comme des instances NewSujet
      #
      def instances
        @instances ||= begin
          h = {}
          PStore::new(app.pstore_new_sujets).transaction do |ps|
            ps.roots.each do |art_id|
              next if art_id == :last_id
              h.merge! art_id => new( art_id )
            end
          end
          h
        end
      end
      
      ##
      # Return TRUE si le sujet de titre +sujet+ existe
      #
      def sujet_existe? sujet
        found = false
        PStore::new(app.pstore_new_sujets).transaction do |ps|
          ps.roots.collect do |root|
            next if root == :last_id
            if ps[root][:titre] == sujet
              found = true
              break
            end
          end
        end
        return found
      end
      
      ##
      #
      # Retourne la liste des thèmes choisis, comme un Array
      # de string
      def get_themes_in_cb
        liste_themes = LISTE_THEMES.collect do |duo|
          if param("cb_#{duo[1]}") == "on"
            duo[1]
          else
            nil
          end
        end.reject { |e| e.nil? }
      end
      
      ##
      #
      # Vérifie les données du sujet dans le formulaire
      #
      # Sert pour la création et l'édition
      #
      def check_param_sujet
        raise NewSujetError, "Vous ne pouvez pas soumettre de sujet !" unless cu.can_submit_subject?
        @art_titre = param(:art_titre).to_s.strip
        raise NewSujetError, "Il faut fournir un titre de sujet !" if @art_titre == ""
        @art_description = param(:art_description).to_s.strip 
        raise NewSujetError, "Merci de décrire un peu ce sujet." if @art_description == ""
      end
      
      
    end # << self App::NewSujet
    
    
    # ---------------------------------------------------------------------
    #
    #   Instances
    #
    # ---------------------------------------------------------------------
    
    attr_reader :id
    
    def initialize sid
      @id = sid.to_i
    end
    
    def save
      data.merge! :updated_at => Time.now.to_i
      PStore::new(app.pstore_new_sujets).transaction { |ps| ps[id] = data }
    end
    
    def remove
      PStore::new(app.pstore_new_sujets).transaction { |ps| ps.delete id }
    end
    
    ##
    #
    # Méthode qui doit transformer le sujet en article avec le
    # path fourni.
    #
    def transform_to_article
      debug "-> transform_to_article"
      raise NewSujetError, "Il faut définir le path…" if path.to_s == ""
      raise NewSujetError, "Un article de même nom existe…" if File.exist? path

      path.concat('.erb') unless path.end_with? '.erb'

      folder = File.dirname full_path
      `if [ ! -d "#{folder}" ];then mkdir -p "#{folder}";fi`
      
      File.open(full_path, 'wb'){ |f| f.write "#{h_titre}\n\n#{h_description}" }
      
      if File.exist? full_path
        ##
        ## Si l'article a été créé, on peut détruire ce sujet
        ##
        remove
        flash "L'article a été créé et le sujet détruit."
        redirect_to path
      else
        error "Le fichier n'a pas pu être créé… Impossible de trouver le fichier."
      end
    rescue NewSujetError => e
      error e.message
    rescue Exception => e
      error e.message
      debug e
    end
    
    def h_titre
      "<h2>#{titre}</h2>"
    end
    
    def h_description
      description.split("\n").collect do |p|
        "#{p}".in_p
      end.join("\n")
    end
    
    def full_path
      @full_path ||= File.join('.', 'public', 'page', 'article', path)
    end
    
    def titre;        @titre        ||= data[:titre]          end
    def description;  @description  ||= data[:description]    end
    def created_at;   @created_at   ||= data[:created_at]     end
    def submiter;     @submiter     ||= data[:submiter]       end
    def valided;      @valided      ||= data[:valided]        end
    def themes;       @themes       ||= data[:themes].split(',') end
    def path;         @path         ||= data[:path]           end
    
    def data
      @data ||= begin
        PStore::new(app.pstore_new_sujets).transaction { |ps| ps.fetch id, nil }
      end
    end
    
    def set_valided
      PStore::new(app.pstore_new_sujets).transaction { |ps| ps[id][:valided] = true }
    end
    def unset_valided
      PStore::new(app.pstore_new_sujets).transaction { |ps| ps[id][:valided] = false }
    end
    
    def set_values
      @data = data.merge!(
        titre:        param(:art_titre),
        description:  param(:art_description),
        themes:       self.class.get_themes_in_cb.join(','),
        path:         param(:art_path)
      )
    end
    
    def dispatch_in_param
      data.each do |k, v|
        case k
        when :themes
          v.split(',').each do |th|
            param("cb_#{th}" => "on")
          end
        when :submiter, :valided, :created_at, :updated_at, :submiter_type
          # Ne rien faire
        else
          param("art_#{k}" => v)
        end
      end
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthodes d'état
    #
    # ---------------------------------------------------------------------
    
    def valided?
      valided == true
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthodes d'helper
    #
    # ---------------------------------------------------------------------
    
    def in_div
      c = ""
      c << edit_buttons
      c << titre.in_div(class: 'titre')
      c.in_div class: 'div_sujet'
    end
    
    def edit_buttons
      btns = ""
      btns << form(operation: 'edit', name: "edit")
      if valided?
        btns << form(operation: 'invalider', name: "invalider") 
      else
        btns << form(operation: 'valider', name: "valider") 
      end
      btns.in_div class: 'small fright edit_btns'
    end
    
    def form data
      f = ""
      f << data[:name].in_span
      f << data[:operation].in_hidden(name: 'operation')
      f << "admin/sujets_soumis".in_hidden(name: 'a')
      f << id.to_s.in_hidden(name: 'art_id')
      f.in_form(class: 'inline', onclick: "this.submit()")
    end
    
  end # NewSujet
end # App