# encoding: UTF-8
=begin

Méthode de contrôleurs utilisés pour la section administration

=end
class App
  
  ##
  #
  # Méthode qui permet de voir les connexions
  #
  def show_connexions
    require_module 'connexions'
    return App::Connexions::show_connexions
  end
  
  ##
  #
  # Section admin de la mailing list
  #
  #
  def show_mailing_list
    require_module 'mailing_list'
    if param( :operation ).to_s != ""
      App::Mailing::send("exec_#{param :operation}".to_sym)
    end
  end
  
  ##
  #
  # Charge le module admin 'articles' pour la gestion des articles
  #
  #
  def module_articles
    raise "Opération impossible" unless offline?
    require_module 'admin/articles'
  end
end