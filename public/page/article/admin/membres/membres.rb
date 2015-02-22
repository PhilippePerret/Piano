# encoding: UTF-8
=begin

Module chargé par la vue admin/membres.erb

=end
class User
  ##
  ## Méthode appelée après l'enregistrement de l'User quand c'est
  ## un nouveau membre
  ##
  ## La méthode procède à ces opérations :
  ##
  ##    * Avertit le nouveau membre (cf. mail_new_membre.erb)
  ##    * Détruit le follower si le membre était un follower
  ##
  ## Noter que lorsque cette méthode est appelée le nouveau membre
  ## a été enregistré et un nouveau ID lui a été fourni
  ##
  def create_as_new_membre
    ##
    ## Envoi du mail
    ##
    data_mail = {
      subject:    "Votre candidature a été accepté",
      message:    app.view('article/admin/membres/mail_new_membre', self.bind)
    }
    debug "Mail envoyé : #{data_mail[:message]}"
    send_mail data_mail
    
    ##
    ## Retrait de la liste des followers (if any)
    ##
    if follower?
      ppstore_remove app.pstore_followers, mail
      debug "User supprimé comme follower."
    end
    
    flash "#{pseudo} a été créé comme nouveau membre. Voir le détail dans le débug."
    flash "Puisque vous êtes OFFLINE, il faut tout de suite actualiser les pstores followers.pstore et membres.pstore." if offline?
  end
end

class App
  current::require_library 'extend_subclass_app'
  class Membres < ExtensionSubclassApp
    class << self
 
      ##
      #
      # Pour afficher une vue du dossier article/admin/membres/
      #
      # Noter que pour toutes ces vues, le self est cette classe contrairement
      # à la vue principale 'membres.erb' qui a pour self l'app (instance App)
      #
      def view vname
        begin
          app.view(File.join('article', 'admin', 'membres', vname), bind)
        rescue RedirectError => e
          ##
          ## En cas de redirection par exemple
          ##
          ""
        rescue Exception => e
          raise e
        end
      end      
      
      ##
      #
      # L'user édité
      #
      #
      def user
        @user ||= begin
          User::new( param('user_id') )
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #     Méthodes d'Helper
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Retourne un menu pour choisir le grade
      #
      #
      def select_grade
        opts = User::GRADES.collect do |grade_id, dgrade|
          dgrade[:hname].in_option(value: grade_id, :selected => (grade_id == user.grade))
        end.join("\n")
        opts.in_select(name: 'user_grade')
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes fonctionnelles
      #
      # ---------------------------------------------------------------------
      
      # Pour l'exposer publiquement
      def bind; binding() end
      
      
    end # << self
  end
end