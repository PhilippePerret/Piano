# encoding: UTF-8
class CommentsError < StandardError; end
class App
  class Operation
    class << self      
      
      
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
        debug e
        error e.message
      end
    end
  end
end