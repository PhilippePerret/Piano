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
    # Défini la liste des commentaires validés et non validés
    #
    def define_comments_valided_or_not
      @comments_valided     = []
      @comments_not_valided = []
      @comments.each do |dcomment|
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
    def add_comments new_comment, user_data
      data_comment = user_data.merge(id: comments.count, ok: false, c: new_comment, at: Time.now.to_i)
      PStore::new(self.class.pstore_comments).transaction do |ps|
        ps[id] << data_comment
      end
    end
    
    ##
    #
    # Validation d'un commentaire par l'administration
    #
    # Noter que comments_id correspond simplement à l'index des données
    # du commentaire dans la liste des commentaires.
    #
    def valider_comments comments_id
      PStore::new(self.class.pstore_comments).transaction do |ps|
        ps[id][comments_id][:ok] = true
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
      c << if cu.trustable? && cu.can_note_article?(id)
        app.view('article/element/cote_form') +
        app.view('article/element/comments_form')
      elsif false == cu.can_note_article?(id)
        ""
      else
        "Vous n'êtes pas un utilisateur de confiance, je ne peux pas vous laisser noter cet article ou le commenter.".in_div
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
            dcom[:c].in_div(class: 'c_content')
          ).in_div(class: 'comment')
        end.join('')
      else
        "Aucun commentaire sur cet article pour le moment.".in_div(class: 'italic small')
      end
      hc.prepend('<a name="lire_comments"></a>')
      return hc
    end
    
    
  end # Article
end # App