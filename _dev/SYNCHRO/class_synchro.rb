class Synchro
  class << self
    
    ##
    ## Les données de hiérarchie online/offline
    ##
    ## C'est un hash dont la clé `:files' contient les données
    ## de la hiérarchie. Chaque clé est le path d'un dossier, chaque valeur
    ## est un hash définissant seulement la clé :files qui est un Array dont
    ## chaque élément est un hash définissant :name, le nom du fichier, et
    ## :mtime, sa date de dernière modification.
    ##
    attr_reader :data_offline
    attr_reader :data_online

    def verbose
      false
    end
    
    ##
    #
    # = main =
    #
    # Méthode principale qui vérifie la synchronisation entre
    # les deux sites
    #
    #
    def check params = nil
      params ||= {}
      init
      get_hierarchie_offline  || return
      get_hierarchie_online   || return
      compare
      if params[:update]
        synchronize_sites
      else
        show_resultat_comparaison
      end
    end
  
    ##
    #
    # = main =
    #
    # Méthode principale qui synchronise les deux sites
    #
    def synchronize
      check :update => true
    end
  
    # ---------------------------------------------------------------------
    #
    #     Méthodes de deuxième niveau
    #
    # ---------------------------------------------------------------------
    
    def files_offline
      @files_offline ||= @data_offline[:files]
    end
    def files_online
      @files_online ||= @data_online[:files]
    end
    ##
    #
    # Compare la hiérarchie des deux sites
    #
    #
    def compare
      puts "*** COMPARAISON ***"
      @resultat_comparaison = {}
      compare_distant_against_local
      compare_local_against_distant
    end
    
    ##
    #
    # Procède à la synchronisation des deux sites d'après
    # le résultat de la comparaison.
    #
    def synchronize_sites
      puts "\n\n\n" + "="*100
      puts "*** SYNCHRONISATION ***"
      @resultat_comparaison.each do |folder_path, folder_files|
        STDOUT.flush
        folder_files.each do |fname, fdata|
          next if fdata[:etat] == 1
          fpath = "#{folder_path}/#{fname}"
          if fdata[:existe_online] === false || fdata[:older] == :offline
            ##
            ## Upload du fichier
            ##
            `ssh #{SERVEUR_SSH} "if [ ! -d \\"./www/#{folder_path}\\" ];then mkdir -p \\"./www/#{folder_path}\\";fi"`
            `scp -p ./#{fpath} #{SERVEUR_SSH}:www/#{fpath}`
            puts "= #{fpath} UPLOADÉ"
          elsif fdata[:existe_offline] === false || fdata[:older] == :online
            ##
            ## Download du fichier
            ##
            ## TODO: Ici, il faudrait pouvoir avoir le choix de détruire
            ## le fichier ONLINE
            ##
            `if [ ! -d "./#{folder_path}" ];then mkdir -p "./#{folder_path}";fi`
            `scp -p #{SERVEUR_SSH}:www/#{fpath} ./#{fpath}`
            puts "= #{fpath} DOWNLOADÉ"
          end
        end
      end
    end
    
    ##
    #
    # Affiche le résultat de la comparaison
    #
    def show_resultat_comparaison
      puts "\n\n\n" + "="*100
      puts "=== RÉSULTAT COMPARAISON ==="

      nombre_bad_files = 0
      
      @resultat_comparaison.each do |folder_path, folder_files|
        folder_files.each do |fname, fdata|
          fpath = "./#{folder_path}/#{fname}"
          nombre_bad_files += 1 unless fdata[:etat] == 1
          if fdata[:etat] == 1
            ##
            ## Fichier OK (synchronisés)
            ##
          elsif fdata[:existe_online] === false
            puts "# #{fpath} inconnu ONLINE"
          elsif fdata[:existe_offline] === false
            puts "# #{fpath} inconnu OFFLINE"
          elsif fdata[:older] == :offline
            puts "# #{fpath} doit être UPLOADÉ"
          elsif fdata[:older] == :online
            puts "# #{fpath} doit être DOWNLOADÉ ou DÉTRUIT"
          end
        end
      end
      
      if nombre_bad_files == 0
        puts "Les deux sites sont parfaitement synchronisés"
      else
        puts "\n\nNombre de fichiers à synchroniser : #{nombre_bad_files}"
      end
    end
    
    ##
    #
    # Compare le site distant au site local
    #
    # Principe : un fichier qui se trouve sur le site local mais
    # pas sur le site distant peut être uploadé
    #
    def compare_distant_against_local
      compare_sites files_offline, files_online, :offline
    end
    ##
    #
    # Compare le site local au site distant
    #
    #
    def compare_local_against_distant
      compare_sites files_online, files_offline, :online
    end
    
    ##
    #
    # Comparaison des fichiers de deux sites
    #
    # +question+ est :offline ou :online
    #     Si :offline, c'est le site distant qu'on compare au site local
    # 
    def compare_sites files_question, files_compare, question
      case question
      when :offline
        lieu      = "LOCAL"
        lieu_comp = "DISTANT"
      when :online
        lieu      = "DISTANT"
        lieu_comp = "LOCAL"
      else
        raise "+question+ doit être :offline ou :online"
      end
      
      files_question.each do |folder_path, folder_files|
        puts "* Dossier #{lieu}: #{folder_path}" if verbose
        ##
        ## Il faut peut-être ajouter ce dossier au résultat de comparaison
        ##
        unless @resultat_comparaison.has_key?(folder_path)
          @resultat_comparaison.merge! folder_path => {}
        end
        
        ##
        ## On prend les données des fichiers de l'autre site
        ##
        ## Si le dossier est inconnu sur l'autre site, c'est une liste
        ## vide.
        ##
        folder_files_compare = 
        if files_compare.has_key?(folder_path) 
          files_compare[folder_path][:files]
        else
          {}
        end
        
        
        ##
        ## On compare chaque fichier (sauf ceux déjà traités)
        ##
        folder_files[:files].each do |fname, fdata|
          ##
          ## Si le fichier a déjà été comparé, on le passe
          ##
          next if @resultat_comparaison[folder_path].has_key?(fname)
          
          ##
          ## Est-ce que le fichier doit être exclu par son extension ?
          ##
          next if EXCLUDED_EXTENTIONS.include?(File.extname(fname))
          
          ##
          ## Est-ce que le fichier doit être exclu par la fin de son affixe ?
          ##
          unless EXCLUDED_END_WITH.nil?
            faffixe = File.basename(fname, File.extname(fname))
            good = true
            EXCLUDED_END_WITH.each do |badend|
              if faffixe.end_with? badend
                good = false
                break
              end
            end
            next unless good
          end
          
          ##
          ## On ajoute ce fichier au résultat de comparaison
          ##
          @resultat_comparaison[folder_path].merge! fname => {
            existe_online: (question == :online ? true : nil),
            existe_offline: (question == :offline ? true : nil),
            older:    nil, # :online ou :offline
            etat:     nil
          }
          
          
          kexiste = question == :online ? :existe_offline : :existe_online
          if folder_files_compare.has_key?(fname)
            @resultat_comparaison[folder_path][fname][kexiste] = true
            ##
            ## Compare les temps
            ## -----------------
            ## Retourne 1 si les fichiers sont synchronisés
            ## Retourne 2 si le premier est plus vieux
            ##          3 si le premier est plus jeune
            res = compare_times_file fdata, folder_files_compare[fname], question
            @resultat_comparaison[folder_path][fname][:etat] = res
            unless res == 1
              @resultat_comparaison[folder_path][fname][:older] = question
            end
          else
            ##
            ## Le fichier n'existe pas sur l'autre site
            ##
            @resultat_comparaison[folder_path][fname][kexiste] = false
          end
        end
      end
    end
    
    ##
    #
    # Compare les temps des fichiers 
    #
    # +question+ est "ONLINE" ou "OFFLINE"
    #
    def compare_times_file dfile_question, dfile_compare, question
      mtime_question = dfile_question[:mtime]
      mtime_compare  = dfile_compare[:mtime]
      fname = dfile_question[:name]
      if mtime_question == mtime_compare
        # => Fichiers synchro
        return 1
      elsif mtime_question > mtime_compare
        # => Premier fichier plus vieux
        return 2
      else
        # => Deuxième fichier plus vieux
        return 3
      end
    end
    
    ##
    #
    # Initialisation : on récupère les données propres à ce site
    #
    def init
      require_relative 'config'
    end
    
  
    def get_hierarchie_online folder = nil
      puts "*** Récupération des données ONLINE…"
      STDOUT.flush
      folder ||= ROOT_FOLDER
      res = `ssh #{SERVEUR_SSH} "ruby synchro.rb \\"#{folder}\\""`
      @data_online = Marshal.load(res)
      show_error_data_online unless @data_online[:ok]
      return @data_online[:ok]
    end
    
    def get_hierarchie_offline folder = nil
      puts "*** Récupération des données OFFLINE…"
      STDOUT.flush
      folder ||= ROOT_FOLDER
      ARGV[0] = folder
      require_relative 'synchro'
      @data_offline = $HIERARCHIE
      show_error_data_offline unless @data_offline[:ok]
      return @data_offline[:ok]
    end
  
    def show_error_data_offline
      puts "# ERROR     : #{@data_offline[:error]}"
      puts "# BACKTRACE : #{@data_offline[:backtrace_error].inspect}"
    end
    ##
    #
    # Affichage de l'erreur de récupération des données distantes
    #
    def show_error_data_online
      puts "# ERROR     : #{@data_online[:error]}"
      puts "# BACKTRACE : #{@data_online[:backtrace_error].inspect}"
    end
  end
end