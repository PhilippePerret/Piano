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
    @is_offline = !online? if @is_offline === nil
    @is_offline
  end
  def online?
    @is_online = (ENV['HTTP_HOST'] != "localhost") if @is_online === nil
    @is_online
  end
end