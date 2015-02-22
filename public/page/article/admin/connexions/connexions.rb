# encoding: UTF-8
=begin

Extensions gérant la section administration des connexions

=end
class App
  class Connexions
  class << self
    
    ##
    #
    # Méthode principale qui affiche les connexions (ONLINE) au site
    #
    #
    def show_connexions
      c = ""
      if download_pstore_articles
        c << "<div>Note : Les analyses sont faites sur la base des données ONLINE qui ont été ramenées en local.</div>"
      end
      c << "Date du pstore connexions : #{htime_pstore_articles}".in_div
      c << "Nombre totale de connexions : #{nombre_total_connexions}".in_div
      c << '<hr />'
      c << "Articles classés par nombre de visites".in_p(class: 'bold')
      c << articles_per_count
      c << "Articles classés par durée de lecture".in_p(class: 'bold')
      c << articles_per_duree
      c << '<hr />'
      return c
    end
    
    
  
    def nombre_total_connexions
      @nombre_total_connexions ||= articles.collect{ |id,da| da[:x] }.inject(:+)
    end
  
    ##
    #
    # Retourne la liste des connexions classées par nombre de connexions
    #
    def articles_per_count
      articles.sort_by{|part, dart| dart[:x]}.collect do |idart, dart|
        "#{dart[:idpath]} : #{dart[:x]} connexions".in_div
      end.reverse.join("\n")
    end
    
    ##
    #
    # Retourne la liste des articles classés par durée de lecture
    #
    def articles_per_duree
      articles.sort_by{|part, dart| dart[:duree_lecture]}.collect do |idart, dart|
        "#{dart[:idpath]} : #{dart[:duree_lecture].as_horloge}".in_div
      end.reverse.join("\n")
    end
  
    ##
    #
    # Tous les articles définis (donc au moins visités une fois)
    #
    # Sauf les articles administration (dossier "admin/")
    #
    def articles
      @articles ||= begin
        h = {}
        PPStore::new(pstore_articles).each_root(except: :last_id) do |ps, idart|
          next if ps[idart][:idpath].start_with? 'admin/'
          h.merge! idart => ps[idart]
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
    def download_pstore_articles
      if pstore_articles_uptodate?
        return false
      else
        `scp piano@ssh.alwaysdata.com:www/#{relpath_pstore} ./#{relpath_pstore}`
        set_last_time :upload_pstore_articles
        return true
      end
    end
  
    ##
    #
    # Retourne true si le pstore a été ramené depuis moins d'une heure
    #
    #
    def pstore_articles_uptodate?
      set_last_time(:upload_pstore_articles)
      return true # TODO: Modifier ensuite
      ltime = last_time(:upload_pstore_articles)
      return false if ltime.nil?
      return ltime > ( Time.now.to_i - 3600 )
    end
  
    def htime_pstore_articles
      @htime_pstore_articles ||= Time.at(last_time(:upload_pstore_articles)).strftime("%d %m %Y : %H:%M") 
    end
  
    def relpath_pstore
      @relpath_pstore ||= File.join('data', 'pstore', 'articles.pstore')
    end
    
    # --- Raccourcis ---
    def pstore_articles
      @pstore_articles ||= App::Article::pstore
    end
    def last_time key
      App::current::last_time key
    end
    def set_last_time key
      App::current::set_last_time key
    end
  
  end
  end
end