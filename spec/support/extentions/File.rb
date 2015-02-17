class File
  class << self
    
    ##
    ## Copie de sauvegarde en détruisant le fichier
    ##
    def unlink_with_rescue path
      return unless exist? path
      FileUtils::mv path, path_rescue(path)
    end
    
    ##
    ## Faire une copie de sauvegarde sans destruction du fichier
    ##
    def make_rescue path
      FileUtils::cp path, path_rescue(path)
    end
    
    ##
    ## Récupérer la copie de sauvegarde du fichier +path+
    ## et le remettre en place.
    ##
    def retrieve_rescue path
      prescue = path_rescue(path)
      raise "Copie de secours introuvable (#{prescue})" unless File.exist? prescue
      File.unlink path if File.exist? path
      FileUtils::mv prescue, path
    end
    def path_rescue path
      "#{path}-rescue"
    end
  end
end
