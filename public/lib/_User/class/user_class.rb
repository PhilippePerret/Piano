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
      udata = PStore::new(app.pstore_followers).transaction do |ps|
        ps.fetch umail, nil
      end
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
      PStore::new(table_mail_to_id).transaction do |ps|
        user_found = ps.fetch(umail, nil)
      end
      unless user_found.nil?
        user_found = User::get( user_found )
      else
        ##
        ## On le cherche dans la table des membres et on
        ## l'enregistre dans la table de correspondance si on
        ## l'a trouvé
        ##
        PStore::new(pstore).transaction do |ps|
          user_ids = ps.roots.reject{|e| e == :last_id}
          user_ids.each do |user_id|
            if ps[user_id][:mail] == umail
              user_found = User::get(user_id)
              break
            end
          end
        end
        unless user_found.nil?
          ##
          ## Il faut l'enregistre dans la table de correspondance
          ##
          PStore::new(table_mail_to_id).transaction do |ps|
            ps[user_found.id]   = user_found.mail
            ps[user_found.mail] = user_found.id
          end
          debug "Donnée ajoutée à la table de correspondance mail<->id (#{user_found.id}&lt;->#{user_found.mail})"
        end
      end
      return user_found
    end
    alias :get_with_mail :get_by_mail
    
    ##
    #
    # Essaie, à chaque chargement de page (required) de récupérer
    # l'utilisateur courant (s'il s'est identifié). Sinon, on
    # fait un user virtuel qui peut être reconnu par son IP ou
    # sa session.
    #
    def retrieve_current
      
      debug "[retrieve_current]"
      debug "app.session['user_id'] : #{app.session['user_id'].inspect}"
      debug "app.session['follower_mail'] : #{app.session['follower_mail'].inspect}"
      debug "app.session['reader_uid'] : #{app.session['reader_uid'].inspect}"
      debug "app.session['session_id'] : #{app.session['session_id'].inspect}"
      
      if app.session['user_id'].to_s != ""
        debug "-> User identifié"
        ##
        ## Ce n'est pas la première connexion de cette
        ## session
        ##
        user_id = app.session['user_id'].to_i
        u     = User::get user_id
        User::current = u
        u.uid = app.session['reader_uid']
        if u.get(:session_id) == app.session.id
          app.session['user_id'] = user_id
          u.instance_variable_set('@is_identified', true)
        end
      elsif app.session['follower_mail'].to_s != ""
        debug "-> Follower reconnu"
        u.uid = app.session['reader_uid']
      else
        u = User::new
        User::current = u # nécessaire pour define_uid
        if app.session['session_id'].to_s != ""
          debug "-> Rechargement simple reader"
          ##
          ## Ce n'est pas la première connexion de cette
          ## session
          ##
          u.uid = app.session['reader_uid']
        else
          debug "-> Toute première connexion"
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
            remote_ip:      app.cgi.remote_addr,
            trustable:      app.cgi.remote_addr.to_s != "",
            reader_uid:     u.uid,
            user_type:      nil,
            membre_id:      nil,
            follower_mail:  nil,
            reader_uid:     nil
            )
        end
      end
      
      ##
      ## On store la date de dernière connexion
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
    # Retourne un hash de tous les utilisateurs
    #
    def all type = nil
      type ||= :all
      @all ||= begin
        h = {all: {}}
        GRADES.keys.each do |gid| h.merge! gid => {} end
        PStore::new(pstore).transaction do |ps|
          user_ids = ps.roots.reject{|e| e == :last_id}
          user_ids.each do |user_id|
            u = User::get(user_id)
            h[:all].merge! user_id => u
            h[ps[user_id][:grade]].merge! user_id => u
          end
        end
        h
      end
      @all[type]
    end
    
  end
end