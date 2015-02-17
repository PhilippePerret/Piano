# encoding: UTF-8
=begin

Module des opération “O”

=end
class CommentsError < StandardError; end
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
          cpwd = Digest::MD5.hexdigest("#{u.get(:password)}#{u.get(:salt)}")
          cpwd_checked = Digest::MD5.hexdigest("#{param('user_password')}#{u.get(:salt)}")
          # debug "[check_login] password : #{u.get(:password)} (dans pstore)"
          # debug "[check_login] password : #{param('user_password')} (donné)"
          # debug "[check_login] salt     : #{u.get(:salt)}"
          # debug "[check_login] cpassword: #{u.cpassword} (dans pstore)"
          # debug "[check_login] cpassword: #{cpwd} (recalculé avec donnée pstore)"
          # debug "[check_login] cpassword: #{cpwd_checked} (avec données fournies)"
          login_ok = cpwd == cpwd_checked
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
        new_data = {:etat => new_etat}
        article_complete = new_etat == 9
        if article_complete
          ##
          ## Article marqué achevé
          ## On ré-initialise ses votes pour pouvoir voter
          ## vraiment pour l'article.
          ##
          new_data.merge! votes: nil
        end
        App::Article::new(article_id).set(new_data)
        mess = "Article #{article_id} mis à l'état #{new_etat}."
        mess << " Les votes de l'article ont été réinitialisés." if article_complete
        flash mess
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
      # Pour coter l'article
      #
      #
      def coter_article
        raise "Pirate !" unless cu.trustable?

        ##
        ## L'article visé par la cote
        ##
        art = App::Article::get(param('article_id').to_i)
        raise "Pirate !" if art.nil? || art.idpath != param('article')
        
        app.require_module 'article/coter_article'
        art.coter_article
        
      end
      
      ##
      #
      # Pour voter pour les articles EN PROJET
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
        ## Est-ce que l'utilisateur peut vraiment voter ?
        ##
        unless cu.can_vote_articles?
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
        
        ##
        ## On enregistre la date de dernier vote du reader
        ##
        cu.set_last_time_vote
        
        flash "Votre vote a bien été enregistré. Merci à vous."
      end
      
      def deposer_commentaire
        return unless cu.trustable?
        
        ##
        ## Si l'user n'est pas identifié, il faut faire un check
        ## sur son email fourni.
        ## Ça peut être un membre, un follower, ou un simple lecteur
        ##
        unless cu.identified?
          umail = param('user_mail').to_s.strip
          raise CommentsError, "Vous devez fournir le mail de votre inscription sur la mailing-list." if umail == ""
          u_com = User::get_by_mail umail
          if u_com.nil?
            raise CommentsError, "Désolé, mais je ne connais aucun follower du cercle avec l'adresse fournie."
          end
        else
          u_com = cu
        end
        
        ##
        ## L'article visé par le commentaire
        ##
        art = App::Article::get( param('aid').to_i )
        
        ##
        ## Les data initiales pour le commentaire
        ##
        data_com = {
          aid:  art.id,
          uid:  u_com.uid,
          ps:   u_com.pseudo,
          c:    param('user_comments').to_s.strip,
          ok:   false, # non validé
          at: Time.now.to_i
        }
        # Note : seul sera ajouté la clé `:i' qui correspondra à
        # l'indice du commentaire dans la liste des commentaires de l'article
        
        ## Le commentaire ne doit pas être vide
        raise CommentsError, "Un commentaire vide n'est pas un commentaire…" if data_com[:c] == ""

        
        ##
        ## Tout est OK, on peut enregistrer provisoirement ce commentaire
        ##
        art.add_comments data_com
        
        ##
        ## On avertit l'administration
        ##
        send_mail_to_admin(
          subject:    "Nouveau commentaire",
          message:    "Admin,\n\nUn nouveau commentaire vient d'être déposé pour l'article ##{art.id} (“#{art.titre}”).\n\nNotez que pour le valider ou le détruire, il faut rejoindre la partie administration ONLINE."
        )

        ##
        ## Message de remerciement à l'user
        ##
        flash "Merci #{u_com.pseudo} pour votre commentaire ! Il apparaitra dès validation par l'administration."
        
      rescue CommentsError => e
        return error e.message
      rescue Exception => e
        debug e.message
        debug e.backtrace.join("\n")
        error e.message
      end
          
    end # << self App::Operation
  end # Operation
end # App