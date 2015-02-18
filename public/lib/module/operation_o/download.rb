# encoding: UTF-8
class App
  class Operation
    class << self
      ##
      #
      # Opération de download du fichier défini dans le paramètre 'o1'
      #
      #      
      def download
        path = param('o1').to_s
        if path == ""
          app.error "Il faut définir le path du fichier à downloader (dans `o1')"
        else
          fichier = Fichier::new(path)
          fichier.download
        end
      end
    end
  end
end