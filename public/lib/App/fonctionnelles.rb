# encoding: UTF-8
=begin

Instance App
Méthodes d'instance fonctionnelles

=end
class App
  
  def initialize
    self.class.current = self
  end
  
  
  ##
  #
  # Exposer le binding
  #
  def bind; binding() end
  
end