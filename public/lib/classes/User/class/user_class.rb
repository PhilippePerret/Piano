# encoding: UTF-8
class User
  class << self
    attr_accessor :current
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
    def each
      all.each do |u_id, u|
        yield u
      end
    end
    
    ##
    #
    # Retourne un hash de tous les utilisateurs
    #
    def all
      @all ||= begin
        h = {}
        PStore::new(pstore).transaction do |ps|
          user_ids = ps.roots
          user_ids = user_ids.reject{|e| e == :last_id}
          user_ids.each do |user_id|
            h.merge! user_id => User::get(user_id)
          end
        end
        h
      end
    end
  end
end