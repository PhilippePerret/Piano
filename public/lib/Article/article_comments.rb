# encoding: UTF-8
=begin

Méthodes d'instance de App::Article gérant les commentaires sur les
articles

=end
class App
  class Article
    
      
    ##
    #
    # @return les commentaires courants
    #
    # +options+ permet de déterminer quels articles on veut.
    #   :valided    Si TRUE, on envoie seulement les commentaires validés
    #               Si FALSE, on envoie seulement les commentaires non
    #               validés.
    #
    def comments options = nil
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
      if options.nil?
        @comments
      elsif options.has_key? :valided
        @comments_valided || define_comments_valided_or_not
        if options[:valided] == true
          ##
          ## Seulement les articles validés
          ##
          @comments_valided
        else
          ##
          ## Seulement les articles non validés
          ##
          @comments_not_valided
        end
      end
    end
    
    ##
    #
    # Définit la liste des commentaires validés et non validés
    #
    def define_comments_valided_or_not
      @comments_valided     = []
      @comments_not_valided = []
      @comments.each do |dcomment|
        next if dcomment[:killed] # passer commentaires détruits
        if dcomment[:ok]
          @comments_valided << dcomment
        else
          @comments_not_valided << dcomment
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
    def add_comments data_com
      data_com = data_com.merge(i: comments.count)
      PStore::new(self.class.pstore_comments).transaction do |ps|
        ps[id] << data_com
      end
    end
    
    def has_comments_valided?
      comments(valided: true).count > 0
    end
    
    
    ##
    #
    # Retourne la section des commentaires
    #
    # Cette section contient le formulaire pour laisser un 
    # commentaire ainsi que tous les commentaires déjà déposés
    #
    def section_comments
      c = ""
      c << '<div style="clear:both;margin-top:2em;border:1px solid #ccc;"></div>'
      if cu.trustable?
        c << app.view('article/element/cote_form') if cu.can_note_article?(id)
        c << app.view('article/element/comments_form')
      else
        "Vous n'êtes pas un visiteur de confiance, je ne peux pas vous laisser noter cet article ou le commenter.".in_div
      end
      c << list_comments.in_fieldset(legend: "Commentaires")
      return c
    end
    
    ##
    #
    # Retourne le listing des commentaires pour affichage dans
    # la page.
    #
    #
    def list_comments
      hc = if has_comments_valided?
        comments(valided: true).collect do |dcom|
          next unless dcom[:ok]
          (
            (dcom[:ps] + ', le ' + dcom[:at].as_human_date).in_div(class: 'c_info') +
            traite_comments(dcom[:c]).in_div(class: 'c_content') + "".in_div(class: 'clear')
          ).in_div(class: 'comment')
        end.join('')
      else
        "Aucun commentaire sur cet article pour le moment.".in_div(class: 'italic small')
      end
      hc.prepend('<a name="lire_comments"></a>')
      return hc
    end
    
    ##
    #
    # Méthode qui met en forme le texte du commentaire
    #
    # Pour le moment, seule les scores sont traités.
    #
    # @return le texte corrigé
    def traite_comments str
      debug "Code original :#{str.gsub(/</, '&lt;')}"
      if str.index("\r")
        if str.index("\n")
          str.gsub!(/\r/, '')
        else
          str.gsub!(/\r/, "\n")
        end
      end
      debug "Retours corrigés :#{str.gsub(/</, '&lt;')}"
      
      str = str.split("\n\n").collect{ |p| "<p>#{p}</p>" }.join('')
      
      
      if str.index('[score:')
        debug "Il y a des scores"
        str.gsub!(/\[score:([0-9]*):([a-z]*)\]/){
          tout = $&
          score_id = $1.to_i
          position = $2.to_s
          Score::div_score_for_comments score_id, position
        }
      end
      
      return str
    end    
    
  end # Article
end # App