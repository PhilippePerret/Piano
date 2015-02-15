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
    def get_with_mail umail
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
    alias :get_by_mail :get_with_mail
    
    ##
    #
    # Essaie, à chaque chargement de page (required), de récupérer
    # l'utilisateur courant (s'il s'est identifié)
    #
    def retrieve_current
      return if app.session['user_id'].to_s == ""
      uid = app.session['user_id'].to_i
      u   = User::get(uid)
      if u.get(:session_id) == app.session.id
        User::current = u
        app.session['user_id'] = uid
        u.instance_variable_set('@is_identified', true)
      end
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