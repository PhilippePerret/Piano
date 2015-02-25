# encoding: UTF-8
class App
  current::require_library 'extend_subclass_app'
  
  # ---------------------------------------------------------------------
  #
  #   Class App::Mailing
  #
  # ---------------------------------------------------------------------
  class Mailing < ExtensionSubclassApp
    class << self
      
      ##
      ## Outil à afficher dans la page
      ##
      attr_reader :outil
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes opérations
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Opération qui affiche l'état de la synchro et permet d'uploader
      # ou de downloader les fichiers.
      #
      def exec_show_synchro
        fic = Fichier::new app.pstore_followers
        @outil = fic.fieldset_synchro :no_check => true
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
        
        ##
        ## Message préformaté ?
        ##
        if param('annonce_new_article') == "on"
          ##
          ## Annonce d'article
          ##
          as_erb    = true
          bind_user = true
          message   = message_new_article
          param(:annonce_titre => "Publication d'un nouvel article")
        else
          ##
          ## Message non préformaté
          ##
          as_erb = param('parse_erb') == "on"
          debug "Le code du message doit être désERBé" if as_erb
          if as_erb
            bind_user = param('bind_user') == 'on'
            debug "L'user doit être bindé" if bind_user
          else
            bind_user = false
          end
          message = param(:annonce_texte)
        end
        
        ##
        ## Traitement du message
        ##
        if as_erb
          begin
            message = ERB::new(message).result(app.bind) if !bind_user
          rescue Exception => e
            raise e
          end          
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
            begin
              data_mail.merge! message: ERB::new(message).result(user.bind)
            rescue Exception => e
              raise e
            end
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
            u = User::get_as_follower duser[:mail]
            begin
              message = ERB::new(message).result(u.bind)
            rescue Exception => e
              raise e
            end
          end
          
          data_mail.merge! to: duser[:mail]
          
          ##
          ## Les followers possède un lien en bas de mail pour
          ## se désinscrire de la mailing liste
          ##
          unsub_link = "vous désinscrire".in_a(href: "http://#{HOST_ONLINE}/?ti=#{duser[:ti_unsub]}&tp=#{duser[:tp_unsub]}")
          unsub_link = "\n\nVous pouvez suivre ce lien pour #{unsub_link}.".in_div(style:'font-size:11pt;margin-top:1em;')

          ##
          ## Message final
          ##
          data_mail[:message] = message + unsub_link
          
          ##
          ## On envoie le mail
          ##
          Mail::new(data_mail).send
          ##
          ## Résultat
          ##
          nombre_envois += 1
          nombre_followers += 1
          debug "MAIL pour #{duser[:pseudo]} (follower)"
        end
        
        
        ##
        ## Message de confirmation
        ##
        flash "Mail envoyé à #{nombre_envois} followers et membres (followers: #{nombre_followers}, membres: #{nombre_membres}) (cf. le détail dans le débug)"
      rescue Exception => e
        err_mess = e.message.gsub(/</, '&lt;')
        error("Une erreur est survenue en désERBant le message : #{err_mess} (voir le backtrace dans le débug)")
        bt = e.backtrace.join("\n")
        debug "### ERREUR : #{err_mess}\n\n#{bt}"
      end
 
      # ---------------------------------------------------------------------
      #
      #   Méthode d'helper
      #
      # ---------------------------------------------------------------------
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
          debug "[show_followers] id:#{id.inspect} : duser:#{duser.inspect}"
          next if @all_mails.has_key? duser[:mail]
          htime = Time.at(duser[:created_at]).strftime("%d %m %Y - %H:%M")
          cbid = "cb-#{id}-follower"
          (
            "&nbsp;&nbsp;#{duser[:pseudo]} - #{duser[:mail]} (#{htime})".in_checkbox(id: cbid, name: cbid, class: 'follower')
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
          PPStore::new(pstore_followers).each_root do |ps, key|
            next if key == :last_id
            h.merge! key => ps[key]
          end
          h
        end
      end
            
      ##
      #
      # @return un follower d'après son mail
      #
      # Retourne NIL si le follower n'existe pas
      #
      def follower umail
        ppdestore pstore_followers, umail
      end
      
      ##
      #
      # Retourne le message pré-formaté pour annoncer un
      # nouvel article.
      #
      # Note : la procédure vérifie aussi que l'article se trouve
      # bien à jour sur le site
      #
      #
      def message_new_article
        art = App::Article::new( param('article_id').to_i )
        fichier = Fichier::new( art.fullpath )
        unless fichier.uptodate?
          fichier.upload
          flash "L'article “#{art.titre}” a été actualisé online."
        end
        flash "Penser à <ol><li>indiquer que l'article n'est plus en projet dans la section administration</li><li>Enlever le “true” dans la table des matières du dossier contenant l'article.</li></ol>"
        <<-HTML
Bonjour <%= pseudo %>,

J'ai le plaisir de vous annoncer la publication d'un nouvel article&nbsp;:

<%= link_to_article(#{art.id}) %>.

Bonne lecture à vous&nbsp;!

Pianistiquement vôtre,

LCP
        HTML
      end
      
     
      # ---------------------------------------------------------------------
      
      
      ##
      #
      # Procédure qui rappatrie le pstore ONLINE en local
      #
      def download_pstore_if_needed
        return false if pstore_uptodate?
        now = Time.now.to_i
        `scp piano@ssh.alwaysdata.com:www/#{relpath_pstore} ./#{relpath_pstore}`
        set_last_time :download_pstore_followers, now
        return true
      end

      def upload_pstore
        now = Time.now.to_i
        `scp ./#{relpath_pstore} piano@ssh.alwaysdata.com:www/#{relpath_pstore}`
        set_last_time :upload_pstore_followers, now
      end
      
      ##
      #
      # Retourne true si le pstore a été ramené depuis moins d'une heure
      #
      #
      def pstore_uptodate?
        ltime = last_time(:download_pstore_followers)
        return false if ltime.nil?
        return ltime > ( Time.now.to_i - 3600 )
      end
      
      def htime_pstore_followers
        @htime_pstore_followers ||= Time.at(last_time(:download_pstore_followers)).strftime("%d %m %Y : %H:%M") 
      end
      
      def pstore_followers; @pstore_followers ||= App::current::pstore_followers end
      
      def relpath_pstore
        @relpath_pstore ||= File.join('data', 'pstore', 'followers.pstore')
      end
  
      
    end # << self Mailing
  end # Mailing
end # App