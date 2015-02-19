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
      img = Score::Image::new param(:id)
      img.data_in_param
    end
    
    ##
    #
    # Demande la destruction de l'image
    #
    def remove_image
      img = Score::Image::new param(:id)
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
            h.merge! img_src => Image::new( img_src )
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
    # facilement une image modifiée.
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
        ps[data_image[:src]] = data_image
      end
      debug "= DATA NEW IMAGE : #{data_image.pretty_inspect}"
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
        reader_id:      cu.uid,
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
      debug "FULL URL : #{fullurl}"
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
    # Pstore contenant les informations sur les images
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
    ## ID dans le pstore
    ##
    attr_reader :id
    
    attr_reader :img_affixe
    attr_reader :img_folder
    attr_reader :img_rh
    attr_reader :img_lh
    
    def initialize id = nil
      @id = id
    end
    
    # ---------------------------------------------------------------------
    #
    #   Opérations principales
    #
    # ---------------------------------------------------------------------

    ##
    #
    # Création de l'image
    #
    def create
      check_values_or_raise_for :create
      data = {
        i:    img_affixe,
        f:    img_folder
      }
      data.merge!( rh: img_rh ) unless img_rh.nil?
      data.merge!( lh: img_lh ) unless img_lh.nil?
      data.merge!( debug: "1")  if param(:cb_debug) == "on"
      resultat = Score::curl_with data
      if resultat[:all_is_ok]
        flash "Création pleine de succès de l'image !"
        if resultat.has_key? :ticket_authentification
          param( 'img_ticket' => resultat[:ticket_authentification] )
          ##
          ## C'est vraiment ici qu'on peut être sûr que l'image
          ## a bien été créée.
          ## On doit l'enregistrer dans le pstore pour conserver son
          ## nom, et son ticket (et d'autres informations moins importantes
          ## comme le follower qui l'a créée, etc.)
          ##
          Score::store_new_image resultat
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
      data = {
        i:    img_affixe,
        f:    img_folder,
        ti:   ticket,
        op:   'remove'
      }
      resultat = Score::curl_with data
      if resultat[:ok]
        if remove_in_pstore
          flash "L'image a été détruite avec succès (PNG + pstore)."
        else
          flash "Le fichier PNG a pu être détruit…"
          error "… mais pas la donnée PStore…"
        end
      else
        error "Problème ne essayant de détruire l'image PNG : #{resultat[:error]}"
      end
    end
    
    ##
    #
    # Détruit l'image dans le pstore
    #
    def remove_in_pstore
      the_id = src # pour ne pas le chercher à l'intérieur
      debug "-> Destruction de donnée pstore #{the_id.inspect}"
      nb_avant, nb_apres = nil, nil
      PStore::new(Score::pstore).transaction do |ps| 
        nb_avant = ps.roots.count.to_i
        ps.delete the_id
      end
      PStore::new(Score::pstore).transaction do |ps| 
        nb_apres = ps.roots.count.to_i
      end
      return nb_apres == nb_avant - 1
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
      when :remove
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
      [:src, :ticket, :folder, :affixe, :right_hand, :left_hand].each do |key|
        hdata.merge! "img_#{key}" => data[key].to_s
      end
      ##
      ## Quelques correction
      ##
      hdata["img_folder"] = hdata["img_folder"].sub(/^img\/cp_score\//,'')
      debug "HDATA POUR PARAM : #{hdata.pretty_inspect}"
      param hdata
    end
    
    
    # ---------------------------------------------------------------------
    #   Data du pstore
    # ---------------------------------------------------------------------
    def folder;   @folder ||= data[:folder] end
    def name;     @name   ||= data[:name]   end
    def affixe;   @affixe ||= data[:affixe] end
    def ticket;   @ticket ||= data[:ticket] end
    def src;      @src    ||= data[:src]    end

    def data
      @data ||= begin
        PStore::new(Score::pstore).transaction { |ps| ps.fetch id, {} }
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
      c << "[edit]".in_a(href: "?a=admin/scores&operation=edit_image&id=#{CGI::escape src}")
      c.in_li(class: 'li_img')
    end
      
  end # / Score::Image
end # / Score