# encoding: UTF-8
=begin

Data pour l'application

=end
class App
  
  attr_reader :params
  
  ##
  #
  # @return l'instance CGI
  #
  def cgi
    @cgi ||= CGI::new('html4')
  end
  
  def param pname
    @params ||= {}
    if pname.class == Hash
      ##
      ## => Définition de paramètres
      ##
      @params.merge! pname
    else
      ##
      ## => Récupération de paramètres
      ##
      @params[pname] ||= cgi[pname.to_s]
    end
  end
  
  def name
    "Le #{short_name}"
  end
  
  def short_name
    "Cercle pianistique"
  end
  
  def offline?
    self.class.offline?
  end
  def online?
    self.class.online?
  end
end