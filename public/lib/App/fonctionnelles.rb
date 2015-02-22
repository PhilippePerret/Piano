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
  def set_last_time key, time = nil
    ppstore pstore_last_times, (time ||= Time.now.to_i)
  end
  
  ##
  #
  # Retourne le temps de dernière opération +key+
  #
  def last_time key
    ppdestore pstore_last_times, key
  end
  
  ##
  #
  # Envoyer un mail à l'administrateur
  #
  #
  def send_mail_to_admin data_mail
    require_library 'mail'
    data_mail.merge!(
      to:               DATA_ADMIN[:mail],
      force_offline:    true
    )
    Mail::new(data_mail).send
  end
  
  ##
  #
  # Exposer le binding
  #
  def bind; binding() end
  
end