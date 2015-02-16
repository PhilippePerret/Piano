# encoding: UTF-8
=begin

Module de gestion administration des commentaires
App::Comments

=end
class App
  class Comments
    class << self
      
      # ---------------------------------------------------------------------
      #
      #   Opérations
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # = main =
      #
      # Méthode principale, appelée en haut de la vue, pour traiter
      # l'opération éventuellement définie
      #
      def exec_operation
        return if param('operation').to_s == ""
        op = param('operation').to_sym
        if self.respond_to? op
          self.send op
        else
          error "L'opération (méthode) `#{op}' est inconnue dans App::Comments (#{app.relative_path(__FILE__).in_span(class:'small')})"
        end
      end
      
      ##
      #
      # Opération de download du fichier distant
      #
      def download
        fic = Fichier::new(App::Article::pstore_comments)
        fic.download
        flash "Pstore des commentaires distant downloadé en local."
      end
      
      ##
      #
      # Détruit le commentaire
      #
      def kill
        flash "Je détruis le commentaire"
      end
      
      ##
      #
      # Valide le commentaire
      #
      def valider
        flash "Je valide le commentaire"
      end
      
      ##
      #
      # Invalider le commentaire
      #
      def invalider
        flash "J'invalide le commentaire"
      end

      # ---------------------------------------------------------------------
      #
      #   Méthodes de données
      #
      # ---------------------------------------------------------------------
      ##
      #
      # Retourne les commentaires répondant au filtre +filtre+
      #
      # +filtre+
      #   :article      ID article - Seulement les commentaires de cet article
      #   :valided      Seulement les commentaires validés
      #   :unvalided    Seulement les commentaires non validés
      #
      def comments filtre
        filtre ||= {}
        arr_comments = []
        only_article_id = filtre.delete(:article)
        only_unvalided  = filtre.delete(:unvalided)
        only_valided    = filtre.delete(:valided)
        PStore::new(App::Article::pstore_comments).transaction do |ps|
          ps.roots.each do |art_id|
            if only_article_id
              next unless art_id == only_article_id
            end
            ps[art_id].each do |dcom|
              if only_unvalided
                next if dcom[:ok] == true
              elsif only_valided
                next if dcom[:ok] == false
              end
              arr_comments << dcom.merge(aid: art_id)
            end
          end
        end
        arr_comments
      end
      
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes d'helper
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Renvoie un listing des commentaires avec les
      # options +options+
      #
      # +options+
      #   :article      Seulement les coms de cet article
      #   :valided      Seulement les articles validés
      #   :unvalided    Seulement les articles non validés
      #   :edition      Si true, on ajoute les boutons d'édition du commentaire.
      #
      def listing_comments options = nil
        options ||= {}
        boutons_edition_needed = true # options.delete(:edition)
        last_article_id = nil
        comments(options).collect do |dcom|
          li = ""
          li << dcom[:aid].to_s.in_hidden(name: 'aid')
          li << "Article ##{dcom[:aid]}".in_div(class: 'small right') unless dcom[:aid] == last_article_id
          li << boutons_edition(dcom) if boutons_edition_needed
          li << (mark_valided(dcom) + '&nbsp;' + dcom[:c]).in_div
          li.in_li
        end.join('')
      end
      
      ##
      #
      # Retourne le div des boutons d'édition du commentaire de data +dcom+
      #
      def boutons_edition dcom
        common_qs = "?a=#{CGI::escape 'admin/comment'}&aid=#{dcom[:aid]}&id=#{dcom[:id]}s&operation="
        b = ""
        b << "kill".in_a(href: common_qs + "kill")
        b << dcom[:ok] ? "Invalider".in_a(href: common_qs + 'invalider') : "Valider".in_a(href: common_qs + "valider")
        b.in_div(class: 'small fright')
      end
      
      ##
      #
      # Retourne la marque de validation d'un article (rond vert/rouge)
      #
      def mark_valided dcomments
        dcomments[:ok] ? rond_vert : rond_rouge
      end
    end # << self App::Comments
  end # Comments
end