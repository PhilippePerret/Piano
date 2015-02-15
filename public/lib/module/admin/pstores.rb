# encoding: UTF-8
=begin

Module administration des pstores

=end
# NOTE : Celui-ci est utilisable en online aussi, donc prudence
raise unless app.offline? || cu.admin?

class App
  class PStores
    class << self
      
      ##
      ## Quand c'est nécessaire, le résultat (code HTML) de l'opération
      ## est mis dans ce code pour être affiché
      ##
      attr_reader :result_operation
      
      ##
      #
      # Évalue un code dans le pstore courant
      #
      def eval_code_in_pstore
        code = param('code_to_eval').to_s.strip
        raise "Il faut définir le code à évaluer" if code == ""
        raise "Il faut choisir le pstore courant dans le menu" if current_pstore.nil?
        PStore::new(current_pstore_path).transaction do |ps|
          eval code
        end
      rescue Exception => e
        mess = e.message.gsub(/</, '&lt;')
        bt = e.backtrace.join("\n")
        debug mess
        debug bt
        return error mess
      end
      
      ##
      #
      # Path au pstore courant ou nil
      #
      def current_pstore_path
        return nil if current_pstore.nil?
        @current_pstore_path ||= begin
          current_pstore.nil? ? nil : File.join(app.folder_pstore, current_pstore)
        end
      end
      
      ##
      #
      # Nom du pstore courant
      #
      def current_pstore
        @current_pstore ||= begin
          ps = param('current_pstore').to_s.strip
          ps = nil if ps == ""
          ps
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes opérations
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Montre l'état de synchronisation entre le fichier local et
      # distant
      #
      def show_synchro
        return if current_pstore.nil?
        @result_operation = fichier_synchro.fieldset_synchro(no_check: true, no_button: true)
      end
      
      ##
      #
      # Uploader le pstore local
      #
      def upload
        return if current_pstore.nil?
        fichier_synchro.upload
        flash "PStore uploadé"
      end
      
      ##
      #
      # Downloader le pstore distant
      #
      def download
        return if current_pstore.nil?
        fichier_synchro.donwload
        flash "PStore downloadé"
      end
      
      ##
      #
      # Détruire le fichier distant
      #
      def remove_distant
        return if current_pstore.nil?
        fichier_synchro.remove_distant
        flash "Fichier distant détruit avec succès."
      end
      
      def fichier_synchro
        @fichier_synchro ||= Fichier::new current_pstore_path
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes d'helper
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # @return le contenu du pstore courant s'il est défini
      #
      def show_content; end # appelé en haut de programme (ne sert à rien)
      def show_data_current
        return "" if current_pstore.nil?
        c = ""
        PStore::new(current_pstore_path).transaction do |ps|
          ps.roots.each do |key|
            value = ps[key]
            value = case value
            when Hash then value_as_hash(value, 1)
            else value.inspect
            end
            c << "#{key.inspect} => #{value}".in_div
          end
        end
        return c.in_fieldset(legend: "Contenu du pstore #{current_pstore}")
      end
      
      def value_as_hash h, tab
        retrait = "#{'&nbsp;' * 8 * tab}"
        h.collect do |k, v|
          v = case v
          when Hash then value_as_hash(v, tab + 1)
          else v.inspect
          end
          "#{retrait}#{k.inspect} => #{v}".in_div
        end.join('').prepend("{").concat("}")
      end
      ##
      #
      # @return le menu select pour les pstores
      #
      #
      def menu_pstores
        pstores_names.collect do |pstore_name|
          pstore_name.in_option(value: pstore_name, selected: (pstore_name == current_pstore))
        end.join('').in_select(id: 'current_pstore', name: 'current_pstore', onchange: "$('form#form_pstore').submit()")
      end
      
      ##
      #
      # Liste des NOMS de pstore
      #
      def pstores_names
        @pstores_names ||= begin
          Dir["./data/pstore/*.pstore"].collect do |path|
            File.basename(path)
          end
        end
      end
      
    end # << self App::PStore
  end # Pstore
end # App