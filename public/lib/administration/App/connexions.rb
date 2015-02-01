# encoding: UTF-8
=begin

Méthodes d'instance pour les connexions, seulement en mode administration
c'est-à-dire en OFFLINE pour le moment.

=end
class App
  
  ##
  #
  # Méthode qui permet de voir les connexions
  #
  def show_connexions
    c = ""
    if download_connexions
      c << "<div>Note : Les analyses sont faites sur la base des données ONLINE qui ont été ramenées en local.</div>"
    end
    c << "Date du pstore connexions : #{htime_pstore_connexions}".in_div
    c << "Nombre totale de connexions : #{nombre_total_connexions}".in_div
    c << '<hr />'
    c << "Connexions classées par nombre de visites".in_p(class: 'bold')
    c << connexions_per_count
    c << '<hr />'
    return c
  end
  
  def nombre_total_connexions
    pstore[:real_nombre_connexions]
  end
  
  ##
  #
  # Retourne la liste des connexions classées par nombre de connexions
  #
  def connexions_per_count
    pstore[:connexions].sort_by{|part, dart| dart[:nombre]}.collect do |part, dart|
      "#{part} : #{dart[:nombre]} connexions".in_div
    end.reverse.join("\n")
  end
  
  ##
  #
  # Toutes les données du pstore des connexions
  #
  #
  def pstore
    @pstore ||= begin
      h = {}
      PStore::new(pstore_connexions).transaction do |ps|
        h.merge! :nombre_connexions => ps[:nombre_connexions]
        keys = ps.roots.reject{|e| e == :nombre_connexions}
        h.merge! :connexions => {}
        real_count_connexions = 0
        keys.each do |article|
          next if article.start_with?('admin/')
          h[:connexions].merge! article => ps[article]
          real_count_connexions += h[:connexions][article][:nombre]
        end
        h.merge! :real_nombre_connexions => real_count_connexions
      end
      h
    end
  end
  
  ##
  #
  # Méthode qui ramène le fichier des connexions ONLINE
  #
  # Note : Elle ne le fait que toutes les heures
  #
  def download_connexions
    if pstore_connexion_uptodate?
      return false
    else
      `scp piano@ssh.alwaysdata.com:www/#{relpath_pstore} ./#{relpath_pstore}`
      set_last_time :upload_pstore_connexions
      return true
    end
  end
  
  ##
  #
  # Retourne true si le pstore a été ramené depuis moins d'une heure
  #
  #
  def pstore_connexion_uptodate?
    ltime = last_time(:upload_pstore_connexions)
    return false if ltime.nil?
    return ltime > ( Time.now.to_i - 3600 )
  end
  
  def htime_pstore_connexions
    @htime_pstore_connexions ||= Time.at(last_time(:upload_pstore_connexions)).strftime("%d %m %Y : %H:%M") 
  end
  
  def relpath_pstore
    @relpath_pstore ||= File.join('data', 'pstore', 'connexions.pstore')
  end
  
end