# encoding: UTF-8
=begin

Data pour l'application

=end
class App
  
  def param pname
    cgi[pname.to_s]
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