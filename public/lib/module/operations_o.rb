# encoding: UTF-8
=begin

Module des opération “O”

=end
class App
  
  class Operation
    class << self
      
      ##
      #
      # Check du login
      #
      def check_login
        login_ok = false
        u = User::get_with_mail param('user_mail')
        unless u.nil?
          require 'digest/md5'
          raise 'user_password est inconnu' if param('user_password').to_s == ""
          raise 'cpassword est inconnu pour l’user' if u.cpassword.to_s == ""
          raise 'Le salt de l’user est inconnu' if u.get(:salt).to_s == ""
          login_ok = u.cpassword == Digest::MD5.hexdigest("#{param('user_password')}#{u.get(:salt)}")
        end
        if login_ok
          u.login
          param('article' => param('na'))
        else
          error "Impossible de vous reconnaitre, merci de ré-essayer."
          param('article' => "user/login")
        end
      end
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
      # Change l'état d'un article
      #
      # La méthode est appelée par Ajax par la section administration
      #
      #
      def change_etat_article
        raise "Pirate !" unless offline?
        article_id  = param('o1').to_i
        new_etat    = param('o2').to_i
        App::Article::new(article_id).set(:etat => new_etat)
        flash "Article #{article_id} mis à l'état #{new_etat}."
      end
      
      ##
      #
      # Détruit une donnée article
      #
      # La méthode est appelée par ajax depuis la section
      # d'administration des articles
      #
      def remove_data_article
        raise "Pirate !" unless offline?
        art  = App::Article::new param('o1').to_i
        if art.remove_data
          app.data_ajax = {ok: true}
          flash "Data de l'article #{art.id} (#{art.idpath}) détruites avec succès."
        else
          error "Impossible de détruire les données de l'article #{art.id} #{art.idpath}…"
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
        PStore::new(App::Article::pstore_votes).transaction do |ps|
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
    end
  end
end