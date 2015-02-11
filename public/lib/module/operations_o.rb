# encoding: UTF-8
=begin

Module des opération “O”

=end
class App
  
  class Operation
    class << self
      
      ##
      #
      # Opération de download du fichier défini dans le paramètre 'o1'
      #
      #      
      def download
        path = param('o1').to_s
        if path == ""
          app.error "Il faut définir le path du fichier à downloader (dans `o1')"
        else
          fichier = Fichier::new(path)
          fichier.download
        end
      end
      
      
      ##
      #
      # Opération d'upload de fichier défini dans le paramètres 'o1'
      #
      #
      def upload
        path = param('o1').to_s
        if path == ""
          app.error "Il faut définir le path du fichier à uploader (dans `o1')"
        elsif File.exist?(path) == false
          app.error "Le fichier `#{path}' est introuvable."
        else
          fichier = Fichier::new(path)
          fichier.upload
        end
      end
      
      ##
      #
      # Pour voter pour les articles
      #
      # Principe : les 20 premiers articles prennent des points de 20 à 1
      # et les autres n'ont rien.
      #
      # Note: Le vote ne peut être enregistré que si l'utilisateur n'a
      # pas encore voté. On le cherche dans la session et dans l'IP
      # Un user peut revoter après deux mois.
      #
      def vote_articles
        ##
        ## Est-ce que l'utilisateur peut voter ?
        ##
        user_ok = true
        deux_mois_plus_tot = Time.now.to_i - 60.days
        PStore::new(pstore_vote_articles).transaction do |ps|
          time_with_ip = ps.fetch(cu.remote_ip, nil)
          unless time_with_ip.nil?
            if time_with_ip > deux_mois_plus_tot
              user_ok = false
            end
          end
          if user_ok
            time_with_session = ps.fetch(app.session.id, nil)
            unless time_with_session.nil?
              if time_with_session > deux_mois_plus_tot
                user_ok = false
              end
            end
          end
          
          # On enregistre ce temps de vote
          if user_ok
            ps[cu.remote_ip]    = Time.now.to_i
            ps[app.session.id]  = Time.now.to_i
          end
          
        end
        unless user_ok
          return error "Vous avez déjà voté pour ces articles."
        end
        
        ##
        ## On peut enregistrer les votes sur les articles
        ##
        ordre = param('o1').split('-').collect{|e| e.to_i}
        PStore::new(App::Article::pstore).transaction do |ps|
          vote = 20
          ordre.each do |article_id|
            ps[article_id][:votes] += vote
            vote -= 1
            break if vote == 0
          end
        end
        
        flash "Votre vote a bien été enregistré. Merci à vous."
      end
      def pstore_vote_articles
        @pstore_vote_articles ||= File.join(app.folder_pstore, 'votes_articles.pstore')
      end
    end
  end
end