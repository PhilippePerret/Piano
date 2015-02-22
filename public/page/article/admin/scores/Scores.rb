# encoding: UTF-8
=begin

Class Stores
------------
Gestion des images créées à l'aide des scripts xextra sur Icare

Extension administration seulement

=end
class Score
  app.require_module 'Score'
  class << self
    attr_reader :logs
    ##
    #
    # Retourne pour affichage les messages de l'opération
    # demandées si elle utilise le log
    #
    def display_logs
      if @logs.nil? || @logs.empty?
        "Aucun message n'a été généré."
      else
        @logs.collect { |m| m.in_div }.join("")
      end
    end
    def log str
      @logs ||= []
      @logs << str
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
    # Rappatrie le fichier ONLINE
    #
    def download_online_pstore
      fichier = Fichier::new Score::pstore
      fichier.download
      flash "Le pstore serveur a été ramené avec succès."
    end
    
    ##
    #
    # Méthode qui nettoie le pstore des scores en retirant les
    # images qui n'existe pas (se produit en cas d'erreur)
    #
    def check_scores
      ##
      ## On récupère toutes les images
      ##
      h = {}
      PPStore::new(pstore).each_root(except: :last_id) do |ps, root|
        next unless root.class == String
        h.merge! root => ps[root]
      end
      ##
      ## On regarde celles qui n'existent plus
      ##
      h.dup.each do |score_src, score_data|
        cmd = "curl #{score_src}"
        res = `#{cmd}`
        if res.index("404 Not Found")
          log "Image #{score_src} introuvable".in_span(class: 'warning')
        else
          log "Image #{score_data[:affixe]} OK"
          h.delete score_src
        end
        # debug "\n*** #{cmd}\nCURL: #{res}"
      end
      
      ##
      ## On détruit celles qui restent
      ##
      ## Note pour le moment, on ne fait rien, jusqu'à ce que
      ## ce soit bon
      ##
      PPStore::new(pstore).transaction do |ps|
        h.each do |score_src, score_data|
          log "Il FAUDRAIT détruire l'image ##{score_data[:id]} #{score_src}"
          log "(POUR LE MOMENT ÇA N'EST PAS ENCORE IMPLÉMENTÉ, IL FAUDRAIT POUVOIR CONFIRMER)"
          # ps.delete score_src
          # ps.delete score_data[:id]
        end
      end
    end
        
    # Traitée dans la vue
    def show_list; end
    
  end # << self Score
  
  # ---------------------------------------------------------------------
  #
  #   Class Score::Image
  #
  # ---------------------------------------------------------------------
  class Image
    
    
    # ---------------------------------------------------------------------
    #
    #   Méthode d'helper
    #
    # ---------------------------------------------------------------------
    
    ##
    # Retourne l'image pour un LI
    #
    # La méthode surclasse la méthode du module pour l'user
    #
    def as_li
      c = ""
      c << src.in_image
      c << affixe.in_span(class: 'affixe')
      c << "[edit]".in_a(href: "?a=admin/scores&operation=edit_image&img_id=#{id}")
      c.in_li(class: 'li_img', id: "li_img-#{id}")
    end
    
  end
  
end