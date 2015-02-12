# encoding: UTF-8
=begin

Module chargé par la vue admin/membres.erb

=end
class App
  current::require_library 'extend_subclass_app'
  class Membres < ExtensionSubclassApp
    class << self
 
      ##
      #
      # Pour afficher une vue du dossier article/admin/membres/
      #
      # Noter que pour toutes ces vues, le self est cette classe contrairement
      # à la vue principale 'membres.erb' qui a pour self l'app (instance App)
      #
      def view vname
        app.view(File.join('article', 'admin', 'membres', vname), bind)
      end      
      
      ##
      #
      # L'user édité
      #
      #
      def user
        @user ||= begin
          User::new( param('user_id') )
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #     Méthodes d'Helper
      #
      # ---------------------------------------------------------------------
      
      ##
      #
      # Retourne un menu pour choisir le grade
      #
      #
      def select_grade
        opts = User::GRADES.collect do |grade_id, dgrade|
          dgrade[:hname].in_option(value: grade_id, :selected => (grade_id == user.grade))
        end.join("\n")
        opts.in_select(name: 'user_grade')
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes fonctionnelles
      #
      # ---------------------------------------------------------------------
      
      # Pour l'exposer publiquement
      def bind; binding() end
      
      
    end # << self
  end
end