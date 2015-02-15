# encoding: UTF-8
=begin

Module de gestion administration des commentaires
App::Comments

=end
class App
  class Comments
    class << self
      
      
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
      #
      def listing_comments options
        comments(options).collect do |dcom|
          (
            dcom[:aid].to_s.in_hidden(name: 'aid') +
            dcom[:c].in_div
          ).in_li
        end.join()
      end
      
    end # << self App::Comments
  end # Comments
end