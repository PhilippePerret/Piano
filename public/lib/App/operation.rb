# encoding: UTF-8
=begin

Méthodes qui gèrent les opérations « o » (toutes les opérations qui ne
peuvent pas être gérées par les vues elles-même)

=end
class App
  
  def opere
    return if param('o').to_s == ""
    App::Operation::send( param('o').to_sym )
  end
  
  ##
  #
  # Retourne un formulaire-boutton pour appeler l'opération
  #
  def form_o args
    o   = args.delete(:o)
    ox  = []
    (1..10).collect do |io|
      k = "o#{io}"
      k_sym = k.to_sym
      break unless args.has_key? k_sym
      ox << args[k_sym].in_hidden(name: k)
    end
    art = args.delete(:article).to_s.in_hidden(name: 'article')
    btn = (args.delete(:button) || args.delete(:titre)).in_submit(class: 'btn')
    (o.in_hidden(name: 'o') + ox.join("") + art + btn).in_form(class: 'form_o')
  end
  
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