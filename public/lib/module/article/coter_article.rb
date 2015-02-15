# encoding: UTF-8
=begin

Module pour coter l'article

=end
class App
  class Article
    
    ##
    #
    # = main =
    #
    # Méthode appelée (par les opérations "o") quand l'user
    # soumet le formulaire pour coter l'article
    #
    def coter_article
      raise "Pirate !" unless cu.trustable?
      
      ##
      ## L'utilisateur peut-il coter l'article ?
      ##
      
      ##
      ## Notes attribuées pour cette cote
      ##
      note_interet = param('note_interet').to_i
      note_clarity = param('note_clarity').to_i
      niveau_user  = param('niveau_user').to_i

      data_cote = {
        i:    note_interet,
        c:    note_clarity,
        n:    niveau_user,
        u:    cu.uid,
        at:   Time.now.to_i
      }
      
      ##
      ## Enregistrement de la cote de l'article
      ##
      art.add_cote data_cote
      
      ##
      ## On indique que l'user ne peut plus coter
      ## cet article
      ##
      cu.add_article_noted art.id
      
      ##
      ## Calcul des cotes totales de l'article
      ##
      note_interet_finale = (art.note_interet||0) + note_interet
      note_clarity_finale = (art.note_clarity||0) + note_clarity
      nombre_cotes        = (art.nombre_cotes||0) + 1
      data_cote_finale = {
        note_interet:       note_interet_finale,
        note_clarity:       note_clarity_finale,
        interet:            (note_interet_finale.to_f / nombre_cotes).round(1),
        clarity:            (note_clarity_finale.to_f / nombre_cotes).round(1),
        nombre_votes:       nombre_cotes
      }
      art.set_cote_finale data_cote_finale
      
      flash "Merci à vous pour votre estimation."
    end
    
    ##
    #
    # Ajouter la cote +dcote+ à l'article
    #
    # +dcote+ est un {Hash} qui contient les données définies
    # ci-dessus
    #
    def add_cote dcote
      PStore::new(self.class.pstore_cotes).transaction do |ps|
        unless ps.roots.include? id
          ps[id] = {cote_finale: nil, cotes: [], updated_at: nil}
        end
        ps[id][:cotes] << dcote
        ps[id][:updated_at] = Time.now.to_i
      end
    end
    
    ##
    #
    # Redéfinit la cote finale de l'article
    #
    # Noter que la méthode `add_cote' ayant forcément été appelée avant
    # cette méthode, l'article possède toujours une donnée dans le pstore
    # des cotes.
    #
    def set_cote_finale dcotef
      PStore::new(self.class.pstore_cotes).transaction do |ps|
        ps[id][:cote_finale] = dcotef
        ps[id][:updated_at]  = Time.now.to_i
      end
    end
    
  end # Article
end # App