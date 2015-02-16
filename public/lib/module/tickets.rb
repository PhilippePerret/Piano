# encoding: UTF-8
=begin

Class App::Ticket
-----------------
Gestion des tickets

=end
class App
  class Ticket
    
    attr_reader :id
    
    def initialize ticket_id = nil
      @id = ticket_id.nil? ? new_id : ticket_id
    end
    
    ##
    #
    # = main =
    #
    # Crée le ticket
    #
    def create_with_code code
      raise "Le code pour créer le ticket doit être un string" unless code.class == String
      @data = {
        id:           id,
        proc:         code,
        protection:   protection
      }
      save
    end
    
    ##
    #
    # = main =
    #
    # Traite le ticket
    #
    def treate protection
      @protection = protection
      return error("Ce ticket a déjà été traité") unless exists? # double appel
      check_or_raise
      begin
        debug "Procédure ticket à évaluer : #{data[:proc]}"
        eval(data[:proc]).call
      rescue Exception => e
        debug e
        error "La procédure ticket a échoué."
      else
        remove
      end
      
    end
    
    ##
    # Produit une erreur si la protection ne correspond pas
    def check_or_raise
      raise "Ce ticket n'est pas sûr, je ne peux pas le jouer." unless data[:protection] == protection
    end
    
    ##
    # Charge le ticket
    #
    def load
      Marshal::load( File.read( path ) )
    end
    
    ##
    #
    def data
      @data ||= load
    end
    
    ##
    #
    # Renvoie la protection définie (traitement) ou initié (création)
    #
    def protection
      @protection ||= Time.now.to_i
    end
    
    ##
    # Sauve le ticket
    #
    def save
      File.open(path, 'wb'){ |f| f.write Marshal::dump( data ) }
    end
    
    ##
    # Détruit le ticket
    #
    def remove
      File.unlink path if exists?
    end
    
    ##
    # @return TRUE si le ticket existe
    def exists?
      File.exist? path
    end
    
    ##
    # @return un nouvel ID pour un ticket
    #
    def new_id
      require 'digest/md5'
      Digest::MD5.hexdigest("#{Time.now.to_i}#{app.session.id}")
    end

    ##
    #
    # Path au ticket
    #
    def path
      @path ||= File.join(app.folder_ticket, id)
    end
    
  end
end