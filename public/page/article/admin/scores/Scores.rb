# encoding: UTF-8
=begin

Class Stores
------------
Gestion des images créées à l'aide des scripts xextra sur Icare

=end
require 'json'
class ScoreError < StandardError; end

class Score

  class << self
    
    ##
    #
    # Méthode qui nettoie le pstore des scores en retirant les
    # images qui n'existe pas (se produit en cas d'erreur)
    #
    def check_scores
      new_id = nil
      PStore::new(pstore).transaction do |ps|
        # TODO
      end
    end
    
    ##
    ## Score::Image courante
    ##
    ## Utiliser Score::current pour y faire appel dans les vues
    ##
    attr_accessor :current
    
    # ---------------------------------------------------------------------
    #
    #   Opérations
    #
    # ---------------------------------------------------------------------

    ##
    #
    # Demande de création de l'image
    #
    def create_image
      img = Score::Image::new
      img.create
      self.current = img if img.ok?
      ##
      ## Si c'est un traitement par Ajax, il faut
      ## mettre les données de l'image créée dans
      ## les données à retourner par ajax
      ##
      if param('ajx') == "1"
        app.data_ajax = { img_data: img.data }
      end
    rescue ScoreError => e
      error e.message
    rescue Exception => e
      debug e
      error "#{e.message} (consulter le log pour le détail)" 
    end
    
    ##
    #
    # Demande d'édition d'une image
    #
    def edit_image
      img = Score::Image::new param(:img_id).to_i
      self.current = img
      img.data_in_param
    end
    
    ##
    #
    # Demande la destruction de l'image
    #
    def remove_image
      img = Score::Image::new param(:img_id).to_i
      img.remove
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthodes sur ensemble images
    #
    # ---------------------------------------------------------------------
    
    ##
    # Exécute un bloc sur l'ensemble des images enregistrées
    #
    def each
      instances.each do | k, v |
        yield v
      end
    end
    
    ##
    # Retourne toutes les images enregistrées comme des
    # instances Score::Image
    #
    def instances
      @instances ||= begin
        h = {}
        PStore::new(pstore).transaction do |ps|
          ps.roots.each do |img_src|
            ##
            ## Pour ne prendre que les sources (src)
            ## Mais on met l'ID en clé et pour instancier
            ## l'image
            next unless img_src.class == String
            img_id = ps[img_src][:id]
            h.merge! img_id => Image::new( id: img_id, src: img_src )
          end
        end
        h
      end
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthodes fonctionnelles
    #
    # ---------------------------------------------------------------------
    
    ##
    #
    # Méthode qui consigne les informations sur l'image qui vient
    # d'être créées, avec les informations +img_data+ (qui correspond au
    # hash qui est retourné par le script-extra en cas de succès)
    #
    # C'est le :src qui est utilisé comme clé, afin de remplacer 
    # facilement une image modifiée. Mais un autre enregistrement consigne
    # un ID unique, qui servira pour la balise [score:<id>] pour l'user
    #
    # @return: La méthode retourne le Hash de données enregistrées,
    # pour disptach immédiat dans l'instance.
    #
    # On conserve principalement :
    #
    #   Valeurs indispensables
    #   ----------------------
    #   - l'affixe de l'image               :affixe
    #   - son ticket d'authentification     :ticket
    #   - le dossier                        :folder
    #   - l'UID du follower/membre          :reader_id
    #   - Source (pour attribut 'src')      :src
    #   - date de création
    #
    #   Valeurs facultatives
    #   --------------------
    #   - ID de l'article (si commentaire)  :article_id
    #
    #
    def store_new_image img_data
      data_image = data_image_from img_data
      PStore::new(pstore).transaction do |ps|
        ##
        ## Nouvel clé/ID
        ##
        img_id  = ps.fetch( :last_id, 0 ) + 1
        img_src = data_image[:src]
        data_image.merge! id: img_id
        ps[img_src]   = data_image
        ps[img_id]    = img_src
        ps[:last_id]  = img_id
        debug "= DATA NEW IMAGE : #{data_image.pretty_inspect}"
      end
      return data_image
    end
    
    ##
    #
    # Retourne le Hash des données à conserver pour l'image dont
    # le résultat de construction a retourné le hash +returned_data+
    #
    def data_image_from returned_data
      rd = returned_data
      {
        affixe:         rd[:image_affixe],
        src:            rd[:img_src],
        ticket:         rd[:ticket_authentification],
        folder:         rd[:local_folder],
        reader_uid:     cu.uid,
        article_id:     app.article.id,
        right_hand:     rd[:right_hand],  # peut être NIL
        left_hand:      rd[:left_hand],   # peut être NIL
        updated_at:     rd[:start_at],
        created_at:     rd[:start_at]
      }
    end
    
    # ---------------------------------------------------------------------
    #
    #   Propriété volatile
    #
    # ---------------------------------------------------------------------
    
    ##
    #
    # Exécute l'opération cUrl avec les paramètres fournis en
    # arguments.
    #
    # Retourne le résultat de l'opération
    #
    def curl_with params
      fullurl = full_url_for params
      # debug "FULL URL : #{fullurl}"
      res = `curl "#{fullurl}"`
      res = JSON::parse(res.force_encoding('utf-8')).to_sym
      debug "\n\nRETURN CURL : #{res.pretty_inspect}"
      res
    end
    
    ##
    #
    # Retourne l'URL complète à appeler par cUrl
    #
    def full_url_for h_qs
      base_url + h2qs( h_qs )
    end
    
    def h2qs hdata # pour “Hash to Query-String”
      hdata.collect { |k, v| "#{k}=#{CGI::escape v}" }.join('&')
    end
    
    def base_url
      @base_url ||= "http://icare.alwaysdata.net/xextra.rb?sc=rlily&"
    end
    
    ##
    #
    # Pstore contenant toutes les informations sur les images
    #
    def pstore
      @pstore ||= File.join(app.folder_pstore, 'scores.pstore')
    end
  end


  # ---------------------------------------------------------------------
  #
  #   Class Score::Image
  #
  # ---------------------------------------------------------------------
  class Image
    
    ##
    ## ID abolu dans le pstore
    ##
    attr_reader :id
    
    attr_reader :img_affixe
    attr_reader :img_folder
    attr_reader :img_rh
    attr_reader :img_lh
    
    ##
    #
    # Instanciation du score
    #
    # Il faut se faire soit par un ID (Fixnum) soit par un Hash avec
    # plusieurs données, comme par exemple l':id et le :src, voire toutes
    # les données
    #
    def initialize idorh = nil
      case idorh
      when Hash   then dispatch idorh
      when Fixnum then @id  = idorh
      when String then @src = idorh
      end
    end
    
    # ---------------------------------------------------------------------
    #
    #   Opérations principales
    #
    # ---------------------------------------------------------------------

    ##
    #
    # @return TRUE si l'image est OK, c'est-à-dire soit qu'elle
    # a bien été construite, soit qu'elle existe vraiment en tant
    # qu'image.
    #
    def ok?
      @is_ok
    end
    ##
    #
    # Création de l'image
    #
    def create
      
      ##
      ## Premier partie : On prend les valeurs soumises
      ## et on les envoie par cUrl aux scripts xextra de
      ## Icare pour fabriquer l'image
      ##
      check_values_or_raise_for :create
      data = {
        i:    img_affixe,
        f:    img_folder
      }
      data.merge!( rh: img_rh ) unless img_rh.nil?
      data.merge!( lh: img_lh ) unless img_lh.nil?
      data.merge!( debug: "1")  if param(:cb_debug) == "on"
      resultat = Score::curl_with data
      
      ##
      ## Deuxième temps : Retour de la création de l'image
      ## On espère que tout s'est bien passé
      ##
      if resultat[:all_is_ok]
        flash "Image créée avec succès !"
        if resultat.has_key? :ticket_authentification
          param( 'img_ticket' => resultat[:ticket_authentification] )
          ##
          ## C'est vraiment ici qu'on peut être sûr que l'image
          ## a bien été créée.
          ## On doit l'enregistrer dans le pstore pour conserver son
          ## nom, et son ticket (et d'autres informations moins importantes
          ## comme le follower qui l'a créée, etc.)
          ##
          dispatch (Score::store_new_image resultat )
          @is_ok = true
        end
      else
        error "L'image n'a pas pu être créée. Consulter le débug pour en comprendre la raison."
      end
    end
    
    ##
    #
    # Destruction d'une image précédemment construite
    #
    def remove
      check_values_or_raise_for :remove
      data_rem = {
        i:    img_affixe,
        f:    img_folder,
        ti:   @ticket,
        op:   'remove'
      }
      resultat = Score::curl_with data_rem
      if !resultat[:ok] && !resultat[:image_unfound]
        return error "Problème en essayant de détruire le fichier PNG : #{resultat[:error]}"
      end
      ##
      ## On essaie quand même de la détruire dans le pstore
      if remove_in_pstore
        flash "L'image a été détruite avec succès."
        reset_data
        data_in_param
      else
        error "Impossible de détruire la donnée Pstore."
      end
    end
    
    ##
    #
    # Détruit l'image dans le pstore
    #
    # Il y a deux enregistrements à détruire : par l'id et par
    # le src.
    #
    def remove_in_pstore
      # Pour ne pas avoir à chercher l'ID et le SRC sur un
      # pstore qui serait verrouillé (ci-dessous)
      image_data = data
      nb_avant, nb_apres = nil, nil # pour control
      PStore::new(Score::pstore).transaction do |ps| 
        nb_avant = ps.roots.count.to_i
        ps.delete image_data[:src]
        ps.delete image_data[:id]
      end
      PStore::new(Score::pstore).transaction do |ps| 
        nb_apres = ps.roots.count.to_i
      end
      debug "= Destruction du score dans le pstore #{image_data[:id]}/#{image_data[:src]}"
      return nb_apres == nb_avant - 2
    end
    
    ##
    #
    # Test des valeurs transmises pour l'opération +op+
    #
    def check_values_or_raise_for op
      @img_affixe = param(:img_affixe).to_s.strip
      raise ScoreError, "Il faut fournir l'affixe de l'image" if @img_affixe == ""
      @img_folder = param(:img_folder).to_s.strip
      raise ScoreError, "L'image se trouve forcément dans un dossier, jamais en racine." if @img_folder == ""
            
      @img_folder.prepend("cp_score/")
      
      case op
      when :create
        @img_rh = param(:img_right_hand).to_s.strip
        @img_rh = nil if @img_rh == ""
        @img_lh = param(:img_left_hand).to_s.strip
        @img_lh = nil if @img_lh == ""
        raise ScoreError, "Il faut donner les notes d'au moins une main !" if "#{@img_rh}#{@img_lh}" == ""
        raise ScoreError, "Votre code est trop long." if "#{@img_rh}#{@img_lh}".length > 300 && param('cb_no_limit_code') != "on"
      when :remove
        @img_id = param(:img_id).to_s.strip
        raise ScoreError, "Il faut l'ID de l'image pour la détruire." if @img_id == ""
        @img_id = @img_id.to_i
        @ticket = param(:img_ticket).to_s.strip
        raise ScoreError, "Il faut fournir le ticket de destruction de l'image (en l'éditant par exemple)" if @ticket == ""
      end
      
    end
    
    # ---------------------------------------------------------------------
    #
    #     Méthodes data
    #
    # ---------------------------------------------------------------------
    
    def dispatch hdata
      hdata.each do |k, v|
        self.instance_variable_set("@#{k}", v)
      end
    end
    
    ##
    #
    # Le contraire du dispatch : quand l'image est éditée, 
    # on prend ses données et on les mets dans les paramètres
    #
    def data_in_param
      hdata = {}
      [:id, :src, :ticket, :folder, :affixe, :right_hand, :left_hand].each do |key|
        if data.nil?
          hdata.merge! "img_#{key}" => ""
        else
          hdata.merge! "img_#{key}" => data[key].to_s
        end
      end
      ##
      ## Quelques correction
      ##
      hdata["img_folder"] = hdata["img_folder"].sub(/^img\/cp_score\//,'')
      debug "HDATA POUR PARAM : #{hdata.pretty_inspect}"
      param hdata
    end
    
    # Après destruction de l'image, on vide @data avant l'appel à 
    # data_in_param pour effacer tous les champ
    def reset_data
      @data = {id: nil, src: nil, ticket: nil, folder: nil, affixe: nil, 
        right_hand: nil, left_hand: nil}
    end
    
    
    # ---------------------------------------------------------------------
    #   Raccourcis pour toutes les données du pstore
    # ---------------------------------------------------------------------
    def src;          @src          ||= data[:src]          end
    def folder;       @folder       ||= data[:folder]       end
    def name;         @name         ||= data[:name]         end
    def affixe;       @affixe       ||= data[:affixe]       end
    def ticket;       @ticket       ||= data[:ticket]       end
    def article_id;   @article_id   ||= data[:article_id]   end
    def reader_uid;   @reader_uid   ||= data[:reader_uid]   end
    def right_hand;   @right_hand   ||= data[:right_hand]   end
    def left_hand;    @left_hand    ||= data[:left_hand]    end
    
    def data
      @data ||= begin
        if @src.nil? && @id.nil? # après la destruction
          {}
        else
          PStore::new(Score::pstore).transaction do |ps|
            @src = ps[@id] if @src.nil? && @id != nil
            @src != nil || raise( "Le :src de l'image devrait être défini pour pouvoir relever ses data…" )
            ps[@src]
          end
        end
      end
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthode d'helper
    #
    # ---------------------------------------------------------------------
    
    def as_li
      c = ""
      c << src.in_image
      c << affixe.in_span(class: 'affixe')
      c << "[edit]".in_a(href: "?a=admin/scores&operation=edit_image&img_id=#{id}")
      c.in_li(class: 'li_img', id: "li_img-#{id}")
    end
    
    def as_image
      "<img src='#{src}' />"
    end
      
  end # / Score::Image
end # / Score