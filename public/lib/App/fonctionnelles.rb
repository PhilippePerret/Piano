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
  # Définit le temps de dernière… opération de clé +key+
  #
  def set_last_time key
    PStore::new(pstore_last_times).transaction do |ps|
      ps[key] = Time.now.to_i
    end
  end
  
  ##
  #
  # Retourne le temps de dernière opération +key+
  #
  def last_time key
    PStore::new(pstore_last_times).transaction do |ps|
      ps.fetch key, nil
    end
  end
  
  ##
  #
  # Exposer le binding
  #
  def bind; binding() end
  
end