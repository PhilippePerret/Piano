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
      # @return le code de tous les membres
      #
      #
      def show_membres
        raise "Inaccessible en ONLINE" if online?
        @all_mails = {}
        all_li = []
        User::each do |user|
          htime = Time.at(user.created_at).strftime("%d %m %Y - %H:%M")
          cbid = "cb-#{user.id}-membre"
          all_li << (
            "&nbsp;&nbsp;#{user.pseudo} - #{user.mail} (#{htime})".in_checkbox(id: cbid, name: cbid, class: 'membre')
          ).in_li
          @all_mails.merge! user.mail => true
        end
        all_li.join("\n").in_ul(id: 'membres', style: "list-style:none;")
      end
      ##
      #
      # Procédure qui affiche tous les followers
      #
      def show_followers
        raise "Inaccessible en ONLINE" if online?
        followers.collect do |id, duser|
          next if @all_mails.has_key? duser[:mail]
          htime = Time.at(duser[:created_at]).strftime("%d %m %Y - %H:%M")
          cbid = "cb-#{id}-follower"
          (
            "&nbsp;&nbsp;#{duser[:name]} - #{duser[:mail]} (#{htime})".in_checkbox(id: cbid, name: cbid, class: 'follower')
          ).in_li
        end.join("\n").in_ul(id: 'followers', style: "list-style:none;")
      end
      
      ##
      #
      # Procédure qui retourne les données de tous les followers
      #
      def followers
        raise "Inaccessible en ONLINE" if online?
        @followers ||= begin
          download_pstore_if_needed
          h = {}
          PStore::new(pstore_mailing).transaction do |ps|
            keys = ps.roots.reject{|e| e == :last_id}
            keys.each do |key|
              h.merge! key => ps[key]
            end
          end
          h
        end
      end
      
      ##
      #
      # Procédure procédant à l'envoi d'une annonce aux followers
      #
      def exec_envoyer_annonce
        raise "Inaccessible en ONLINE" if online?
        require_library 'mail'
        require './data/secret/data_tilleul'
        
        ##
        ## Pour dire aux méthodes (pour le moment link_to) d'utiliser
        ## des urls complètes
        ##
        app.use_full_urls = true
        
        ##
        ## Pour dire aux méthodes (link_to pour le moment) d'utiliser
        ## des liens (<a>) plutôt que des formulaires
        ##
        app.use_links_a = true
        
        as_erb = param('parse_erb') == "on"
        debug "Le code du message doit être désERBé" if as_erb
        if as_erb
          bind_user = param('bind_user') == 'on'
          debug "L'user doit être bindé" if bind_user
        else
          bind_user = false
        end
        message = param(:annonce_texte)
        
        if as_erb
          message = ERB::new(message).result(app.bind) if !bind_user
        else
          ##
          ## Il faut vérifier que le texte soit bien un texte
          ## sans ERB
          ##
          if message.index('<%')
            error "Ce message comporte des balises ERB (&lt;%). Or, la case n'est pas cochée. Merci de supprimer ces codes, qui ne seraient pas traités, ou de cocher la case correspondante."
            return
          end
        end
        
        ##
        ## Les données de base du mail
        ##
        data_mail = {
          to:             nil,
          from:           DATA_TILLEUL[:mail],
          subject:        param(:annonce_titre),
          message:        message,
          force_offline:  true
        }
        
        
        nombre_envois     = 0
        nombre_followers  = 0
        nombre_membres    = 0
        @all_recevers     = {}
        
        ##
        ## Envoi du mail aux membres choisis
        ##
        User.each do |user|
          next unless param("cb-#{user.id}-membre") == "on"
          data_mail.merge! to: user.mail
          
          ##
          ## Messages personnalités
          ##
          if bind_user
            data_mail.merge! message: ERB::new(message).result(user.bind)
          end
          
          ##
          ## On envoie le mail
          ##
          Mail::new(data_mail).send
          
          ##
          ## Résultat
          ##
          nombre_envois += 1
          nombre_membres += 1
          debug "MAIL pour #{user.pseudo} (membre)"
          
          ##
          ## On mémorise le mail pour ne pas l'envoyer à un membre
          ## qui serait dans la mailing-list
          ##
          @all_recevers.merge! user.mail => true
        end
        
        followers.each do |id, duser|
          next unless param("cb-#{id}-follower") == "on"
          next if @all_recevers.has_key? duser[:mail]
          @all_recevers.merge! duser[:mail] => true # on ne sait jamais…

          ##
          ## Si l'user doit être bindé, on utilise une astuce : on
          ## crée des instances provisoires (avec un ID commençant à 1000000
          ## au cas où il y ait un risque) d'user. Mais seules les dates
          ## de création de le pseudo seront définis.
          ##
          ## Mais noter que ça lèvera une erreur si on utilise une donnée
          ## qui n'est pas définie.
          ##
          if bind_user
            u = User::new
            u.instance_variable_set('@data', {
              pseudo:       duser[:name],
              created_at:   duser[:created_at],
              id:           (1000000 + id)
            })
            data_mail.merge! message: ERB::new(message).result(u.bind)
          end
          
          data_mail.merge! to: duser[:mail]

          ##
          ## On envoie le mail
          ##
          Mail::new(data_mail).send
          ##
          ## Résultat
          ##
          nombre_envois += 1
          nombre_followers += 1
          debug "MAIL pour #{duser[:name]} (follower)"
        end
        
        
        ##
        ## Message de confirmation
        ##
        flash "Mail envoyé à #{nombre_envois} followers et membres (followers: #{nombre_followers}, membres: #{nombre_membres}) (cf. le détail dans le débug)"
      end
      
      # ---------------------------------------------------------------------
      
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
        ## On ajoute l'utilisateur dans le pstore des followers
        ##
        nombre_followers = PStore::new(pstore_mailing).transaction do |ps|
          last_id = ps.fetch(:last_id, 0) + 1
          ps[last_id]   = {mail: param(:user_mail), name: param(:user_name), created_at: Time.now.to_i}
          ps[:last_id]  = last_id
          ps.roots.count - 1
        end

        ##
        ## On avertit l'admin de la nouvelle inscription
        ##
        require_module 'mail'
        App::current::send_mail_to_admin(
          from:       param(:user_mail),
          subject:    "Nouveau follower pour le #{short_name}",
          message:   "Admin\n\nUn nouvel utilisateur s'est inscrit à la mailing list : #{param :user_mail}.\n\nRien à faire, c'est juste une information. Pour information aussi, le nombre de followers du site est actuellement de #{nombre_followers} personnes."
        )
    
      rescue Exception => e
        error e.message
      end
      
      ##
      #
      # Check les valeurs transmises pour l'ajout à la mailing list
      #
      def check_value_add_mailing_list_or_raise
        uname     = param(:user_name).strip
        umail     = param(:user_mail).strip
        umailconf = param(:user_mail_confirmation).strip
        ureponse  = param(:user_reponse).strip.downcase
        raise "Vous devez fournir un nom ou un pseudo." if uname == ""
        raise "Vous devez fournir votre mail, pour qu'on puisse vous avertir." if umail == ""
        raise "Vous devez fournir la confirmation de votre mail." if umailconf == ""
        raise "Votre confirmation de mail ne correspond pas… Merci de le vérifier." if umail != umailconf
        raise "Ce mail est déjà dans la mailing-list !" if mail_exists_in_mailing?(umail)
        unless ["un pianiste", "pianiste", "claviériste", "un claviériste", "clavieriste", "un clavieriste"].include? ureponse
          raise "Êtes-vous un robot ? Dans le cas contraire, merci de répondre correctement à la question anti-robot."
        end
      rescue Exception => e
        raise e
      end
  
      ##
      #
      # Vérifie que l'adresse n'existe pas déjà 
      #
      def mail_exists_in_mailing? mail
        found = false
        PStore::new(pstore_mailing).transaction do |ps|
          ps.roots.reject{|e| e == :last_id}.each do |id|
            if ps[id][:mail] == mail
              found = true
              break
            end
          end
        end
        return found
      end
      
      ##
      #
      # Procédure qui rappatrie le pstore ONLINE en local
      #
      def download_pstore_if_needed
        return false if pstore_uptodate?
        `scp piano@ssh.alwaysdata.com:www/#{relpath_pstore} ./#{relpath_pstore}`
        set_last_time :download_pstore_mailing
        return true
      end

      def upload_pstore
        `scp ./#{relpath_pstore} piano@ssh.alwaysdata.com:www/#{relpath_pstore}`
      end
      
      ##
      #
      # Retourne true si le pstore a été ramené depuis moins d'une heure
      #
      #
      def pstore_uptodate?
        ltime = last_time(:download_pstore_mailing)
        return false if ltime.nil?
        return ltime > ( Time.now.to_i - 3600 )
      end
      
      def htime_pstore_mailing
        @htime_pstore_mailing ||= Time.at(last_time(:download_pstore_mailing)).strftime("%d %m %Y : %H:%M") 
      end
      
      def pstore_mailing; @pstore_mailing ||= App::current::pstore_mailing end
      
      def relpath_pstore
        @relpath_pstore ||= File.join('data', 'pstore', 'mailing_list.pstore')
      end
  
      
    end # << self Mailing
  end # Mailing
end # App