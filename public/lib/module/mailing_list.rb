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
      # Procédure qui affiche tous les followers
      #
      def show_followers
        raise "Inaccessible en ONLINE" if online?
        followers.collect do |id, duser|
          htime = Time.at(duser[:created_at]).strftime("%d %m %Y - %H:%M")
          (
            "&nbsp;&nbsp;#{duser[:name]} - #{duser[:mail]} (#{htime})".in_checkbox(id: "cb-#{id}", name: "cb-#{id}")
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
        data_mail = {
          to:             nil,
          from:           DATA_TILLEUL[:mail],
          subject:        param(:annonce_titre),
          message:        param(:annonce_texte),
          force_offline:  true
        }
        nombre_envois = 0
        followers.each do |id, duser|
          if param("cb-#{id}") == "on"
            data_mail.merge! to: duser[:mail]
            Mail::new(data_mail).send
            nombre_envois += 1
            debug "MAIL pour #{duser[:name]}"
          else
            debug "PAS DE MAIL pour #{duser[:name]}"
          end
        end
        flash "Mail envoyé à #{nombre_envois} followers (cf. le détail dans le débug)"
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