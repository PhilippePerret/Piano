# encoding: UTF-8
=begin

Module appelé quand l'application raise et que l'administrateur
est détecté (par l'IP distante ou locale).

=end
require 'fileutils'
class Admin
  class << self
    attr_reader :messages
    def log str
      @messages << str
    end
    def check
      @messages = []
      log "Administrateur détecté."
      check_pstores
      
      return_messages
    end
    
    ##
    #
    # Méthode qui check les pstores, les abort tous
    #
    def check_pstores
      folder_pstores = File.join('.', 'data', 'pstore')
      Dir["#{folder_pstores}/**/*.pstore"].each do |path|
        FileUtils::cp path, "#{path}-copie"
        FileUtils::rm path
        FileUtils::mv "#{path}-copie", path
      end
    end
    
    
    def return_messages
      @messages.collect{ |m| "<div>#{m}</div>"}.join("\n")
    end
  end # << self
end
