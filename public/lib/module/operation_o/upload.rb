# encoding: UTF-8
class App
  class Operation
    class << self      
      
      ##
      #
      # Opération d'upload de fichier défini dans le paramètres 'o1'
      #
      #
      def upload
        path = param('o1').to_s
        if path == ""
          app.error "Il faut définir le path du fichier à uploader (dans `o1')"
        elsif File.exist?(path) == false
          app.error "Le fichier `#{path}' est introuvable."
        else
          fichier = Fichier::new(path)
          fichier.upload
        end
      end
    end
  end
end