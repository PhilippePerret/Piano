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
      ## On regarde celles qui n'existe plus
      ##
      h.dup.each do |score_src, score_data|
        res = `curl -h "#{score_src}"`
        debug "\n*** #{score_src}\nCURL: #{res}"
      end
      ##
      ## On détruit celles qui restent
      ##
      ## Note pour le moment, on ne fait rien, jusqu'à ce que
      ## ce soit bon
      ##
      PPStore::new(pstore).transaction do |ps|
        h.each do |score_src, score_data|
          debug "Il FAUDRAIT détruire l'image ##{score_data[:id]} #{score_src}"
          # ps.delete score_src
          # ps.delete score_data[:id]
        end
      end
    end
    
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