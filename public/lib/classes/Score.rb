# encoding: UTF-8
=begin

Class Score minimale, simplement pour les commentaires à afficher

=end
class Score
  
  class << self
    
    ##
    #
    # @return le DIV à insérer dans un commentaire
    #
    def div_score_for_comments score_id, position
      src = PStore::new(pstore).transaction do |ps|
        ps.fetch score_id.to_i, nil
      end
      if src.nil?
        debug "# Impossible de trouver le score ##{score_id}"
        return "[Extrait de partition introuvable…]"
      end
      src.in_img.in_div(class: "score #{position}")
    end
    
    
    ##
    #
    # Pstore contenant toutes les informations sur les images
    #
    def pstore
      @pstore ||= File.join(app.folder_pstore, 'scores.pstore')
    end
    
  end # << self
  
end