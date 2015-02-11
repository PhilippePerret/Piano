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