# encoding: UTF-8
class String
  
  class << self
    
    def base_application
      @base_application ||= begin
        File.expand_path '.'
      end
    end
    def reg_base_application
      @reg_base_application ||= begin
        /#{Regexp::escape base_application}/
      end
    end

  end # << self
  
  ##
  # Transforme une path absolue en path relative
  #
  # NOTE
  #
  #   * Si la classe App existe et définit la méthode
  #     de classe `relative_path_of', on l'utilise, sinon, on
  #     calcul la "base" de l'application.
  #
  def as_relative_path
    if defined?(App) && App.respond_to?( :relative_path_of)
      App::relative_path_of self
    else
      rel_path = self.gsub(String::reg_base_application, '')
      rel_path.prepend(".") unless rel_path.start_with?('.') || (rel_path == self)
      return rel_path
    end
  end
  
  
  # Ruby version < 2
  unless "".respond_to?(:prepend)
    def prepend str
      self.replace "#{str}#{self}"
    end
  end
  
  unless "".respond_to?(:capitalize)
    def capitalize
      s = self
      s[0..0].upcase + s[1..-1]
    end
  end
      
  def numeric?
    Float(self) != nil rescue false
  end
    
  # Chamelise ('mon_nom_tiret' => 'MonNomTiret')
  def camelize
    self.split('_').collect{|mot| mot.capitalize}.join("")
  end

  # Transformer les caractères diacritiques et autres en ASCII
  # 
  unless defined? DATA_NORMALIZE
    DATA_NORMALIZE = {
      :from => "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
      :to   => "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
    }
  end
  def normalize
    self.tr(DATA_NORMALIZE[:from], DATA_NORMALIZE[:to])
  end

  # Pour un nom de fichier sans problème
  def as_normalized_filename
    self.normalize.gsub(/ +/, '_').gsub(/[^a-zA-Z0-9\._]/, '').gsub(/_+/, '_').gsub(/^_/,'').gsub(/_$/,'')
  end

  # Transforme la chaine en “id normalizé”, c'est-à-dire un 
  # identifiant de type String, ne contenant que des lettres et
  # des chiffres, avec capitalisation de la première lettre de
  # chaque mot.
  # Par exemple :
  #     "Ça c'est l'été et mon titre" => "CaCestLeteEtMonTitre"
  def as_normalized_id separateur = nil
    separateur ||= ""
    self.normalize.gsub(/[^a-zA-Z0-9 ]/, separateur).downcase.split.collect{|m|m.capitalize}.join('')
  end

  # Retire les slashes
  # 
  def strip_slashes
    self.gsub(/\\(['"])/, '\\1')
  end
  
end