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
  # Requérir le module de nom +module_name+
  #
  def require_module module_name
    require File.join(folder_module, module_name)
  end
  def require_library lib_name
    require File.join(folder_library, lib_name)
  end
  
  ##
  #
  # Exposer le binding
  #
  def bind; binding() end
  
end