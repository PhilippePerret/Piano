# encoding: UTF-8
class App
  current::require_library 'extend_subclass_app'
  
  ##
  #
  # Pour ajouter un follower
  #
  # Note: C'est l'utilisateur qui procède à cette opération
  #
  def add_to_mailing_list
    App::Mailing::add
  end
  
  # ---------------------------------------------------------------------
  #
  #   Class App::Mailing
  #
  # ---------------------------------------------------------------------
  class Mailing < ExtensionSubclassApp
    class << self
           
           
      ##
      #
      # Procédure d'ajout d'un user à la mailing list
      #
      # Cette procédure est utilisée quand un utilisateur s'inscrit à la 
      # mailing-list
      #
      def add
        check_value_add_mailing_list_or_raise
    
        ##
        ## Le mail du nouveau follower
        ##
        umail = param(:user_mail)

        ##
        ## On crée un ticket de désinscription pour le 
        ## follower
        ##
        app.require_module 'tickets'
        tck_unsubscribe = App::Ticket::new
        code = "Proc::new{ User::get_as_follower('#{umail}').unsubscribe }"
        tck_unsubscribe.create_with_code code
        
        ##
        ## On ajoute l'utilisateur dans le pstore des followers
        ##
        nombre_followers = PPStore::new(pstore_followers).transaction do |ps|
          last_id = ps.fetch(:last_id, 0) + 1
          ps[umail]   = {
            id:         last_id, 
            mail:       umail, 
            pseudo:     param(:user_pseudo),
            ti_unsub:   tck_unsubscribe.id,
            tp_unsub:   tck_unsubscribe.protection,
            created_at: Time.now.to_i
          }
          ps[:last_id]  = last_id
          ps.roots.count - 1
        end

        ##
        ## On avertit l'admin de la nouvelle inscription
        ##
        send_mail_to_admin(
          from:       param(:user_mail),
          subject:    "Nouveau follower pour le #{short_name}",
          message:   "Admin\n\nUn nouvel utilisateur s'est inscrit à la mailing list : #{param :user_mail}.\n\nRien à faire, c'est juste une information. Pour information aussi, le nombre de followers du site est actuellement de #{nombre_followers} personnes."
        )
    
      rescue Exception => e
        error e.message
        debug "Class erreur : #{e.class}"
        bt = e.backtrace.join("\n")
        mess_err = e.message.gsub(/</, '&lt;')
        debug "#{mess_err}\n\n#{bt}"
      end
      
      ##
      #
      # Check les valeurs transmises pour l'ajout à la mailing list
      #
      def check_value_add_mailing_list_or_raise
        uname     = param(:user_pseudo).strip
        umail     = param(:user_mail).strip
        umailconf = param(:user_mail_confirmation).strip
        ureponse  = param(:user_reponse).strip.downcase
        raise "Vous devez fournir un nom ou un pseudo." if uname == ""
        raise "Vous devez fournir votre mail, pour qu'on puisse vous avertir." if umail == ""
        raise "Vous devez fournir la confirmation de votre mail." if umailconf == ""
        raise "Votre confirmation de mail ne correspond pas… Merci de le vérifier." if umail != umailconf
        raise "Ce mail est déjà dans la mailing-list !" if follower_exists?(umail)
        unless ["un pianiste", "pianiste", "claviériste", "un claviériste", "clavieriste", "un clavieriste"].include? ureponse
          raise "Êtes-vous un robot ? Dans le cas contraire, merci de répondre correctement à la question anti-robot."
        end
      rescue Exception => e
        raise e
      end
  
      ##
      # @return TRUE si le follower de mail +umail+ existe
      def follower_exists? umail
        ppdestore( pstore_followers, umail ) != nil
      end
      def pstore_followers; @pstore_followers ||= App::current::pstore_followers end      
    end # << self Mailing
  end # Mailing
end # App