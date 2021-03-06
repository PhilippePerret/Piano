# encoding: UTF-8
=begin

Module définissant la classe App::Cron qui permet de lancer les cron-jobs

Il peut être utiliser par en cron normal ou depuis la section
administration (section “Cron-Job”)

@usage

    Appeller
       App::Cron::run
    pour lancer les opérations

=end

##
## Constante qui est mise à true lorsque le cron est lancé de façon
## automatique, pas forcé depuis l'administration.
##

MODE_CRON = false unless defined? MODE_CRON

require './public/lib/required' # quand appelé seul

class App
  class Cron
  class << self
    
    # Dossier "cron" au même niveau que ce cron.rb
    def folder
      @folder ||= File.join('.', 'public', 'lib', 'module', 'cron')
    end
    
    ##
    ## Si TRUE, le cron ne fait rien mais dit simplement
    ## ce qu'il ferait. Principalement en mode administration
    ##
    attr_accessor :noop
    
    ##
    ## Si TRUE, pas de date/temps dans les logs
    ##
    attr_accessor :no_date
    
    ##
    ## Si TRUE, pas de préfixe "---" dans les logs
    ##
    attr_accessor :no_pref
    
    ##
    ## Définir à la volée un préfixe
    ##
    attr_accessor :log_pref
    
    ##
    ## Mettre à true pour voir les infos complètes des
    ## pstores
    ##
    attr_accessor :full_infos
    
    attr_reader :logs
    
    ##
    # Enregistrer un message
    def log str
      @logs ||= []
      datepref = no_date ? "" : "[#{Time.now.to_i.as_human_date(false, true)}] "
      normpref = no_pref ? "" : "--- "
      mess_log = "#{log_pref.nil? ? '' : log_pref}#{normpref}#{datepref}#{str}"
      @logs << mess_log
      mainlog str
    end
    
    ##
    def mainlog mess
      return unless MODE_CRON
      reflog.write "--- [#{Time.now}] #{mess}\n"
    end
    def log_error e
      log e.message + "\n" + e.backtrace.join("\n")
    end
    def reflog
      @reflog ||= File.open(log_path, 'a')
    end
    def log_path
      @log_path ||= File.expand_path( File.join('..', 'cron.log') )
    end
    
    def run
      mainlog "-> App::Cron::run"

      ##
      ## Initialisation
      ##
      init_cron

      log "=== Lancement du cron job#{noop ? ' (MODE NO-OP)' : ''} ===\n\n"
      
      
      ##
      ## Dispatche dans les articles les données enregistrées au
      ## cours de la journée dans les pstores connexions
      ##
      dispatch_data_pstores_session

      ##
      ## On affiche quelques informations statistiques
      ##
      statistiques

      App::Cron::no_pref  = true
      App::Cron::no_date  = true
      App::Cron::log_pref = "".rjust(10)

      ##
      ## Enregistrement dans les données des articles
      ## Si noop, on ne fait qu'afficher les résultats
      ##
      App::Cron::Article::save_data
      
      ##
      ## Enregistrement dans les données reader
      ## Si noop, on ne fait qu'afficher les résultats
      ##
      App::Cron::Reader::save_data

      App::Cron::no_pref  = true
      App::Cron::no_date  = true
      App::Cron::log_pref = ""

      ##
      ## Destruction des Pstores (simulation seulement
      ## si noop)
      ##
      App::Cron::PStore::remove_pstores
      
      ##
      ## Nettoyage du site
      ##
      clean_up
      
      mainlog "<- App::Cron::run"
      log "\n\n=== Fin du cron job ===\n"
    end
    
    ##
    #
    # Quelques informations statistiques
    #
    def statistiques
      mainlog "-> App::Cron::statistiques"
      
      log "\n" + "-"*80
      log "= Statistiques =\n"
      
      ##
      ## Nombre d'IP enregistrées
      ##
      nb_ips = ::PPStore::new(app.pstore_ip_to_uid).transaction { |ps| ps.roots.count }
      log "Nombre d'IPs enregistrées : #{nb_ips}"

      ##
      ## Nombre de membres
      ##
      nb_membres = ::PPStore::new(app.pstore_membres).transaction { |ps| ps.roots.count - 1 }
      log "Nombre de membres : #{nb_membres}"
      
      ##
      ## Nombre de followers
      ##
      nb_followers = ::PPStore::new(app.pstore_followers).transaction { |ps| ps.roots.count - 1 }
      log "Nombre de followers : #{nb_followers}"
      
      ##
      ## Nombre de Readers
      ##
      nb_readers = ::PPStore::new(app.pstore_readers).transaction { |ps| ps.roots.count - 1 }
      log "Nombre de readers : #{nb_readers}"
      
      log "\n" + ("-"*80) + "\n"

      mainlog "<- App::Cron::statistiques"
    end
    
    ##
    #
    # On envoie un mail à l'administrateur avec le log
    # des opérations
    #
    def result_to_admin
      mainlog "-> App::Cron::result_to_admin"
      app.require_library 'mail'
      data_mail = {
        subject:    "Résultat du cron-job du #{Time.now.to_i.as_human_date(true, true)}",
        message:    <<-HTML
Admin, voilà le résultat du cron-job courant :

#{logs.join("\n")}
        HTML
      }
      send_mail_to_admin data_mail
      mainlog "<- App::Cron::result_to_admin"
    end
    
    # ---------------------------------------------------------------------
    #
    #   Méthodes fonctionnelles
    #
    # ---------------------------------------------------------------------
    
    ##
    #
    # Méthode appelée au début du run
    #
    def init_cron
      require_all_modules
    end
    
    ##
    #
    # Requiert tous les modules du dossier /cron
    #
    def require_all_modules
      Dir["#{folder}/**/*.rb"].each { |m| require m }
    end
    
    # ---------------------------------------------------------------------
    #
    #   Opérations de cron
    #
    # ---------------------------------------------------------------------
    
    def dispatch_data_pstores_session
      log "\n\n*** Dispatch des données des pstores-sessions ***\n"
      log "INFO: Seuls sont traités les pstores-sessions dont la date\n" +
          "      de dernière modification est supérieure à l'heure\n"+
          "      courante.\n"
      il_y_a_une_heure = Time.now.to_i - 3600
      @log_pref = "    "
      Dir["./tmp/pstore_session/**"].each do |path|
        ps = App::Cron::PStore::new path
        if ps.updated_at < il_y_a_une_heure
          log "\n>>> #{ps.affixe} : TRAITEMENT"
          traite_pstore_session ps
          App::Cron::PStore << ps
        else
          log "\n--- #{ps.affixe} : TROP JEUNE"
          ps.log_pretty_data if full_infos
        end
      end
      @log_pref = ""
    end
    
    ##
    #
    # Traitement d'un pstore session
    #
    # +ps+ est une instance App::Cron::Pstore
    #
    def traite_pstore_session ps
      ps.log_pretty_data if full_infos 
      log "reader-uid : #{ps.reader_uid}"
      if ps.reader_uid.nil? && ps.remote_ip != nil
        uid = User::get_uid_from_ip ps.remote_ip
        unless uid.nil?
          "reader-id par IP : #{uid}"
        end
      end
      
      ##
      ## Le lecteur, si on peut le définir
      ##
      ## Noter que pour le moment, il ne sert à rien d'autre
      ## qu'à marquer sa date de dernière connexion.
      ##
      reader = uid.nil? ? nil : App::Cron::Reader::get( uid )
      
      ##
      ## On ajoute ce pstore à la liste des pstores du reader
      ## s'il est défini
      ##
      reader.add_pstore ps unless reader.nil?
      
      log "Nb articles : #{ps.articles.count}"
      if ps.articles.count > 0
        ps.traite_articles reader
      end
    end
    
    
    
    
  end # << self App::Cron
  
    class PStore
      
      
      class << self
        
        attr_reader :instances
        
        ##
        #
        # Ajoute une instance assez vieille pour être
        # traitée
        #
        def << pstore
          @instances ||= []
          @instances << pstore
        end
        
        ##
        #
        # Détruit tous les pstores traités
        # (seulement si noop n'est pas true)
        #
        def remove_pstores
          return if @instances.nil? || @instances.empty?
          @instances.each { |pstore| pstore.remove }
        end
      
      end # << self App::Cron::Pstore
      
      attr_reader :path
      
      # Raccourcis
      def noop; App::Cron::noop end
      def log foo; App::Cron::log foo end
      def full_infos; App::Cron::full_infos end
      
      def initialize path
        @path = path
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes de cron job
      #
      # ---------------------------------------------------------------------
      
      ##
      # Traitement des articles du pstore
      #
      def traite_articles reader
        
        ##
        ## Traitement de chaque article
        ##
        articles.each do |art_id, art_data|
          article = App::Cron::Article::get art_id
          log "*** Traitement article #{art_id}"
          log_pretty_data_article art_data if full_infos
          # :id, :start, :end, :duree, :discontinue
          
          article.add_connexion
          article.add_duree art_data[:duree]
          
          unless reader.nil?
            ##
            ## Plus tard, on pourra consigner les articles lus dans
            ## la données reader, si c'est nécessaire.
            ##
            
            ##
            ## On mémorise la date de dernière connexion, en prenant
            ## toujours dans `set_last_connexion' la plus tardive
            ##
            reader.set_last_connexion( art_data[:end] || art_data[:start] )
          end
          
        end
        
      end
      
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes d'helper
      #
      # ---------------------------------------------------------------------
      def log_pretty_data_article data_article
        pretty_hash data_article
      end
      
      def log_pretty_data
        pretty_hash data
      end
      
      def pretty_hash h
        h.each do |k, v|
          log "#{k.inspect} => #{v.inspect}"
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes fonctionnelles
      #
      # ---------------------------------------------------------------------
      
      ## Le détruit
      def remove
        if File.exist? path
          File.unlink path unless noop
          log "* #{noop ? 'Détruira' : 'REMOVE'} pstore #{affixe}"
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #   Méthodes de données
      #
      # ---------------------------------------------------------------------
      
      ## Nom et affixe du fichier
      def articles;     @articles     ||= get(:articles, [])  end
      def reader_uid;   @reader_uid   ||= get(:reader_uid)    end
      def remote_ip;    @remote_ip    ||= get(:remote_ip)     end
      def updated_at;   @updated_at   ||= get(:updated_at)    end
      def user_type;    @user_type    ||= get(:user_type)     end
      def id;           @id           ||= get(:id)            end
      def follower_mail;@follower_mail||= get(:follower_mail) end
      def membre_id;    @membre_id    ||= get(:membre_id)     end

      def name;         @name         ||= File.basename(path) end
      def affixe;       @affixe       ||= File.basename(path, File.extname(path)) end
      
      def get key, def_value = nil
        res = ppdestore path, {key => def_value}
        res[key]
      end
      
      def data
        @data ||= begin
          h = {}
          PPStore::new(path).each_root do |ps, root|
            h.merge! root => ps[root]
          end
          h
        end
      end

    end # / App::Cron::Pstore
  
    # ---------------------------------------------------------------------
    #
    #   Classe App::Cron::Article
    #
    # ---------------------------------------------------------------------
    
    class Article
      class << self
      
        # Raccourcis
        def log str; App::Cron::log str end
        def noop; App::Cron::noop end
        
        ##
        # Retourne l'instance App::Cron::Article en l'instanciant
        # si nécessaire
        #
        def get art_id
          @instances ||= {}
          unless @instances.has_key? art_id
            @instances.merge! art_id => new(art_id)
          end
          @instances[art_id]
        end
      
      
        ##
        #
        # Enregistre les données dans le pstore des articles
        #
        def save_data
          if @instances.nil? || @instances.empty?
            log "\nAucun article à traiter."
            return
          end
          
          log "\n\n"
          log "   === ARTICLES ==="
          log "-------------------------"
          log "|    ID    NB   DURÉE   |"
          log "-------------------------"
          @instances.each do |art_id, cron_art|
            
            log "| #{art_id.to_s.rjust(5)}"+
              "#{cron_art.connexions.to_s.rjust(6)}"+
              "#{cron_art.duree.to_s.rjust(8)}"+
              "|".rjust(4)
            
            ##
            ## Exécuter l'opération si noop n'est pas nil
            ##
            unless noop
              article = App::Article::get art_id
              article.add_connexions  cron_art.connexions
              article.add_duree       cron_art.duree
            end
          end
          log "-------------------------"
          
        end
        
      end # << self
    
      # ---------------------------------------------------------------------
      #
      #   Instance App::Cron::Article
      #
      # ---------------------------------------------------------------------
    
      attr_reader :id
      attr_reader :connexions
      attr_reader :duree
      
      def initialize art_id
        @id = art_id
        @connexions   = 0
        @duree        = 0
      end
      
      def add_connexion
        @connexions += 1
      end
      
      def add_duree duree
        duree ||= 60
        @duree += duree
      end
    
    end # / App::Cron::Article
    
    
    # ---------------------------------------------------------------------
    #
    #   Class App::Cron::Reader
    #
    # ---------------------------------------------------------------------
    class Reader
      
      # ---------------------------------------------------------------------
      #
      #   Classe
      #
      # ---------------------------------------------------------------------
      class << self
        
        attr_reader :instances
        
        # Raccourcis
        def noop; App::Cron::noop end
        def log foo; App::Cron::log foo end
        def full_infos; App::Cron::full_infos end
        
        
        def get reader_uid
          @instances ||= {}
          unless @instances.has_key? reader_uid
            @instances.merge! reader_uid => new(reader_uid)
          end
          @instances[reader_uid]
        end
        
        ##
        #
        # Enregistre les données dans les données reader
        #
        def save_data
          if @instances.nil? || @instances.empty?
            log "\nAucun reader à traiter."
            return 
          end
          
          log "\n"
          log "          === READERS ==="
          log "-----------------------------------"
          log "|  UID    TYPE     LAST CONNEXION  |"
          log "-----------------------------------"
          @instances.each do |reader_uid, reader|
            
            ##
            ## Data affichées
            ##
            log "|" + "#{reader_uid}".rjust(5) +
                "#{reader.get_type}".rjust(9) +
                "#{reader.last_connexion}".rjust(16) +
                "    |"
            
            unless noop
              ##
              ## Consignation des données
              ##
              u = User::new
              u.uid = reader_uid
              u.store_reader(
                last_connexion: reader.last_connexion
              )
            end
          end
          log "-----------------------------------\n\n"
        end
      end
      
      # ---------------------------------------------------------------------
      #
      #   Instances
      #
      # ---------------------------------------------------------------------
      
      attr_reader :uid
      
      attr_reader :last_connexion
      
      attr_reader :pstores
      
      attr_reader :user_id
      attr_reader :follower_mail
      
      def initialize reader_uid
        @uid = reader_uid
        @last_connexion = 0
        @pstores        = []
      end
    
      # Raccourcis
      def noop; App::Cron::noop end
      def log foo; App::Cron::log foo end
      def full_infos; App::Cron::full_infos end
      
      ##
      #
      # Consigne la date +time+ la plus tardive qui
      # lui est transmise
      #
      def set_last_connexion time
        return if time.nil?
        @last_connexion = time if time > last_connexion
      end
      
      ##
      #
      # Ajoute un pstore (App::Cron::Pstore) au reader
      #
      def add_pstore ps
        @pstores << ps
      end
      
      ##
      #
      # Retourne le type de l'user
      # Retourne "Membre", "Follower" ou "Reader"
      def get_type
        type = "Reader"
        pstores.each do |pstore|
          if pstore.membre_id != nil
            @user_id = pstore.membre_id
            type = "Membre"
            break
          elsif pstore.follower_mail != nil
            type = "Follower"
            @follower_mail = pstore.follower_mail
            break
          end
        end
        return type
      end
    
    end # / Classe Reader
    
  end # Cron
end # App