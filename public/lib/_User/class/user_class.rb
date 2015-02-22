# encoding: UTF-8
class User
  class << self
    
    ##
    ## User courant (on peut utiliser la fonction `cu')
    ##
    attr_accessor :current
    
    ##
    ## Hash des instances d'user instanciés
    ##
    attr_reader   :instances

    ##
    #
    # Retourne l'utilisateur d'ID +user_id+
    #
    def get user_id
      @instances ||= {}
      unless @instances.has_key? user_id
        @instances.merge! user_id => User::new( user_id )
      end
      @instances[user_id]
    end
    
    ##
    #
    # Retourne un follower comme instance User
    #
    # Retourne NIL si le follower n'existe pas
    #
    def get_as_follower umail
      udata = ppdestore app.pstore_followers, umail
      return nil if udata.nil?
      u = User::new
      udata[:id] += 1000000 # pour éviter les problèmes
      udata.each do |k, v|
        u.instance_variable_set("@#{k}", v)
      end
      return u
    end
    
    ##
    #
    # Retourne l'user dont le mail est +umail+
    #
    def get_by_mail umail
      user_found = nil
      user_found = ppdestore table_mail_to_id, umail
      unless user_found.nil?
        user_found = User::get( user_found )
      else
        ##
        ## On le cherche dans la table des membres et on
        ## l'enregistre dans la table de correspondance si on
        ## l'a trouvé
        ##
        PPStore::new(pstore).each_root(except: :last_id) do |user_id|
          if ps[user_id][:mail] == umail
            user_found = User::get(user_id)
            break
          end
        end
        # PPStore::new(pstore).transaction do |ps|
        #   user_ids = ps.roots.reject{|e| e == :last_id}
        #   user_ids.each do |user_id|
        #     if ps[user_id][:mail] == umail
        #       user_found = User::get(user_id)
        #       break
        #     end
        #   end
        # end
        unless user_found.nil?
          ##
          ## Il faut l'enregistrer dans la table de correspondance
          ##
          duser = {
            user_found.mail => user_found.id,
            user_found.id   => user_found.mail
          }
          ppstore table_mail_to_id, duser
          debug "Donnée ajoutée à la table de correspondance mail<->id (#{user_found.id}&lt;->#{user_found.mail})"
        end
      end
      return user_found
    end
    alias :get_with_mail :get_by_mail
    
    ##
    #
    # Retourne l'UID d'user correspondant à l'IP +rip+
    # ou nil
    #
    def get_uid_from_ip rip
      ppdestore app.pstore_ip_to_uid, rip
    end
    
    ##
    #
    # Essaie, à chaque chargement de page (required) de récupérer
    # l'utilisateur courant (s'il s'est identifié). Sinon, on
    # fait un user virtuel qui peut être reconnu par son IP ou
    # sa session.
    #
    def retrieve_current
      
      debug "[retrieve_current]"
      debug "app.session['session_id'] : #{app.session['session_id'].inspect}"
      debug "app.session['reader_uid'] : #{app.session['reader_uid'].inspect}"
      debug "app.session['user_id'] : #{app.session['user_id'].inspect}"
      debug "app.session['follower_mail'] : #{app.session['follower_mail'].inspect}"
      
      if app.session['user_id'].to_s != ""
        ##
        ## Ce n'est pas la première connexion de cette
        ## session
        ##
        user_id = app.session['user_id'].to_i
        u     = User::get user_id
        
        ## Cf. N0001
        if u.get(:session_id) != app.session.id
          debug "Session-ID différent du session-id enregistré à l'identification -> retour à la page d'identification."
          app.session['user_id'] = nil
          flash "Merci de vous identifier à nouveau."
          redirect_to :login
          return
        end
        
        User::current = u
        u.uid = app.session['reader_uid']
        u.instance_variable_set('@is_identified', true)
      elsif app.session['follower_mail'].to_s != ""
        u.uid = app.session['reader_uid']
      else
        u = User::new
        User::current = u
        if app.session['session_id'].to_s != ""
          ##
          ## Ce n'est pas la première connexion de cette
          ## session
          ##
          u.uid = app.session['reader_uid']
          debug "= UID en session : #{u.uid.inspect}"
          if u.uid.nil?
            # Problème… encore et toujours… marre…
            u.define_uid
            debug "= UID redéfini (-> #{u.uid} / en session : #{app.session['reader_uid']})"
          end
        else
          ##
          ## C'est la toute première connexion de cette
          ## session
          ##
         
          ##
          ## On définit l'UID du visiteur seulement quand il
          ## arrive sur le site.
          ##
          u.define_uid
          
          ##
          ## On met l'ID de la session en session
          ##
          app.session['session_id'] = app.session.id
          
          ##
          ## On enregistre les données de connexion
          ##
          u.store( 
            connexion:      Time.now.to_i,
            deconnexion:    nil,
            remote_ip:      app.cgi.remote_addr,
            trustable:      app.cgi.remote_addr.to_s != "",
            reader_uid:     u.uid,
            articles:       {}, # articles lus au cours de cette session
            user_type:      nil,
            membre_id:      nil,
            follower_mail:  nil
            )
        end
      end
      
      ##
      ## On store la date de dernière connexion (dans le pstore
      ## session provisoire)
      ##
      u.set_last_connexion
      
      
      debug "[/retrieve_current]"
    end
    
    ##
    #
    # Boucle sur chaque utilisateur
    #
    #
    def each type = nil
      all(type).each do |u_id, u|
        yield u
      end
    end
    
    ##
    #
    # Retourne un hash de tous les membres
    #
    def all type = nil
      type ||= :all
      @all ||= begin
        h = {all: {}}
        GRADES.keys.each do |gid| h.merge! gid => {} end
        PPStore::new(pstore).each_root(except: :last_id) do |ps, user_id|
          u = User::get user_id
          h[:all].merge! user_id => u
          h[ps[user_id][:grade]].merge! user_id => u
        end
        h
      end
      @all[type]
    end
    
  end
end