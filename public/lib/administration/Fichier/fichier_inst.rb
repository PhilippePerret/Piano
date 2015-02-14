# encoding: UTF-8
=begin

Class Fichier pour SSH
----------------------

Permet de gérer la synchronisation entre un serveur local et un serveur distant.
Régler ci-dessous les données propres à l'application courante.
Cf. DATA PROPRES À L'APPLICATION COURANTE

@usage

    fichier = Fichier::new <path> # path avec ou sans './' peu importe

@methodes

    fichier.fielset_synchro[ <options>]
        Retourne un code HTML à insérer dans la page pour afficher l'état
        de synchronisation du fichier +fichier+. Si +options+ définit
        :no_check => true, on affiche simplement les dates des deux fichiers
        distant et local, avec boutons pour downloader ou uploader.

    fichier.message_compare_time
        Compare les temps du fichier distant et du fichier local et retourne
        un message approprié.

    fichier.serveur_to_local / fichier.download
        Fait une copie du fichier distant en local
        @Note : on copie de précaution est toujours fait du fichier local.

    fichier.local_to_serveur / fichier.upload
        Fait une copie du fichier local vers le site distant

=end
class Fichier
  
  class << self
    
    # ---------------------------------------------------------------------
    #   DATA PROPRES À L'APPLICATION COURANTE
    #
    
    ##
    ## Serveur SSH
    ##
    def serveur
      @serveur ||= "piano@ssh.alwaysdata.com"
    end
    
    ##
    ## Pstore pour enregistrer les dates d'upload et de download
    ##
    def pstore
      @pstore ||= File.join(app.folder_pstore, 'synchros.pstore')
    end
    
    #
    #
    #   FIN DES DATA PROPRES
    # ---------------------------------------------------------------------
    
    
    
    def relative_path_of path
      if @root === nil
        @root = File.expand_path('.')
      end
      if path.start_with?('./')
        path[2..-1] 
      else
        path.sub(/^#{@root}\//, '')
      end
    end
    
    def get_last_time_of path, sens = :upload
      key = "#{path}-#{sens}"
      PStore::new(pstore).transaction do |ps|
        ps.fetch key, nil
      end
    end
    def set_last_time_of path, sens = :upload
      key = "#{path}-#{sens}"
      PStore::new(pstore).transaction do |ps|
        ps[key] = Time.now.to_i
      end
    end
    
  end # << self
  
  ##
  ## Le path au fichier
  ##
  attr_reader :path
  
  ##
  ## Les options envoyés
  ##
  attr_reader :options
  
  def initialize path
    @path = Fichier::relative_path_of path
    @options = {}
  end
  
  ##
  #
  # Pour afficher le fieldset de synchro du fichier
  # C'est un fieldset qui indique l'état de synchronisation et propose un
  # bouton pour updater le fichier online si c'est nécessaire
  #
  # +options+
  #   :show_filename  Si TRUE, affiche le nom du fichier
  #   :message        Si défini, ajoute un message au-dessus du message de 
  #                   synchro
  #   :article        L'article vers lequel il faut retourner après 
  #                   l'opération
  #   :no_check       Si TRUE, la méthode ne fait pas de vérification mais
  #                   relève seulement la date de chaque fichier 
  #                   distant/local et présente les deux boutons pour uploader
  #                   ou downloader
  #                   Default: FALSE
  #
  def fieldset_synchro options = nil
    options ||= {}
    @options = options
    <<-HTML
<fieldset id="synchronisation_local_distant">
  <legend>Synchronisation local/distant</legend>
  #{options[:message] || ""}
  #{message_synchro}  
</fieldset>
    HTML
  end
  
  ##
  #
  # Compare les dates de la version locale et distante et retourne le
  # message adéquat.
  #
  # Propose éventuellement un bouton pour update le fichier local.
  #
  def message_synchro
    tloc = mtime_local
    tdis = mtime_distant
    mess = []
    if options[:no_check] == true
      
      rond_local    = tloc >= tdis ? rond_vert : rond_rouge
      rond_distant  = tdis >= tloc ? rond_vert : rond_rouge
      
      th = tloc == 0 ? "Inexistant" : tloc.as_human_date(false, true)
      mess << "#{rond_local}&nbsp;Fichier local   : #{th}&nbsp;&nbsp;".in_div(class: 'pre')
      mess << "                  Last upload : #{last_upload true}".in_div(class: 'pre')
      th = tdis == 0 ? "Inexistant" : tdis.as_human_date(false, true) 
      mess << "#{rond_distant}&nbsp;Fichier distant : #{th}&nbsp;&nbsp;".in_div(class: 'pre')
      mess << "                  Last download : #{last_download true}".in_div(class: 'pre')
      if tloc != tdis
        mess << (button_download + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + button_upload).in_div
      end
    else
      if tloc == tdis
        mess << "Les deux fichiers local/distant #{options[:show_filename] ? '\"#{path}\" ' : ''}sont synchronisés."
      else
        if tloc > tdis
          # mess << "Le fichier local `#{path}' est plus à jour que le fichier distant".in_div
          if online?
            ## C'est idiot puisque je ne peux pas vérifier QUAND je suis ONLINE…
            mess << "Si vous faites des modifications, des problèmes vont survenir. Il serait plus prudent d'actualiser le fichier distant.".in_div(class: 'warning')
          else
            mess << "Le fichier distant doit être actualisé pour être à jour.".in_div
            mess << button_upload.in_div(class: 'right air')
          end
        else
          if online?
            ## C'est idiot puisque je ne peux pas vérifier quand je suis online…
            mess << "Vous pouvez faire des modifications en toute tranquilité, puis rappatrier le fichier distant en local.".in_div
          else
            mess << "Le fichier distant `#{path}' est plus à jour que le fichier local.".in_div
            mess << "Si vous faites des modifications, des problèmes vont survenir. Il serait plus prudent d'actualiser le fichier local en utilisant le bouton ci-dessous.".in_div(class: 'warning')
            mess << button_download.in_div(class: 'right air')
          end
        end
      end
    end
    mess.join('')
  end
  alias :message_compare_time :message_synchro
  
  
  ##
  #
  # Retourne le bouton pour uploader le fichier local
  #
  def button_upload
    form_o(o: "upload", o1: path, button: "Actualiser le fichier distant", article: options[:article], class: 'small inline')
  end
  
  ##
  #
  # Retourne le bouton pour downloader le fichier distant
  #
  def button_download
    form_o(o: "download", o1: path, button: "Actualiser le fichier local", article: options[:article], class: 'small inline')
  end
  
  ##
  #
  # Retourne la date du dernier upload du fichier local
  # Retourne NIL s'il n'a pas encore été uploadé
  # 
  # Si +as_human+ est true, retourne la date au format humain,
  # avec les minutes.
  #
  def last_upload as_human = false
    lastu = self.class::get_last_time_of path, :upload
    if lastu.nil?
      return nil unless as_human
      return "(jamais uploadé)"
    else
      lastu = lastu.as_human_date(false, true) if as_human
      return lastu
    end
  end
  
  ##
  #
  # Retourne la date du dernier download du fichier distant
  # Retourne NIL s'il n'a pas encore été downloadé
  #
  # Si +as_human+ est true, retourne la date au format humain,
  # avec les minutes.
  #
  def last_download as_human = false
    lastd = self.class::get_last_time_of path, :download
    if lastd.nil?
      return nil unless as_human
      return "(jamais downloadé)"
    else
      lastd = lastd.as_human_date(false, true) if as_human
      return lastd
    end
  end
  
  # ---------------------------------------------------------------------
  #
  #   Opérations sur le fichier
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # Destruction du fichier distant
  #
  #
  def remove_distant
    `ssh #{Fichier::serveur} "if [ -f ./www/#{path} ];then rm ./www/#{path};fi"`
  end
  
  ##
  #
  # Rappatrie le fichier distant en local
  #
  # @alias: def download
  def serveur_to_local
    folders_upto :local
    copie_local
    res = `scp -p #{Fichier::serveur}:www/#{path} ./#{path}`
    ok = res == ""
    self.class::set_last_time_of( path, :download ) if ok
    return ok
  end
  alias :download :serveur_to_local
  
  ##
  #
  # Actualise sur le serveur le fichier en prenant le
  # fichier local
  #
  # @alias : def upload
  def local_to_serveur
    folders_upto :distant
    res = `scp -p ./#{path} #{Fichier::serveur}:www/#{path}`
    ok = res == ""
    self.class::set_last_time_of( path, :upload ) if ok
    return ok
  end
  alias :upload :local_to_serveur
  
  
  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------
  
  
  ##
  #
  # @return TRUE si les deux fichiers distant/local ont la même date
  #
  #
  def uptodate?
    mtime_local == mtime_distant
  end
  
  ##
  #
  # Retourne la date de dernière modification du fichier local
  #
  def mtime_local
    return 0 unless local_exists?
    File.stat(path).mtime.to_i
  end
  
  ##
  #
  # Retourne la date de dernière moficiation du fichier distant
  #
  #
  def mtime_distant
    return 0 unless distant_exists?
    res = `ssh #{Fichier::serveur} "ruby -e \\"puts File.stat('#{path_distant}').mtime.to_i\\""`
    res.to_i
  end
  
  ##
  #
  # Return TRUE si le fichier/dossier local existe
  #
  #
  def local_exists?
    File.exist? path
  end
  alias :local_exist? :local_exists?
  
  ##
  #
  # Return TRUE si le fichier/dossier distant existe
  #
  #
  def distant_exists?
    res = `ssh #{Fichier::serveur} "if [ -f ./www/#{path} ];then echo \\"1\\";else echo \\"0\\";fi"`
    return res.strip == "1"
  end
  alias :distant_exist? :distant_exists?
  
  ##
  # Procédure qui a deux rôles : s'assurer que la hiérarchie de
  # dossier existe jusqu'au fichier (cette instance) et la créer le
  # cas échéant.
  ##
  # Note: La procédure fonctionne en local comme en distant. En distant,
  # on fait appel à un script qui charge cette procédure et utilise cette
  # même méthode pour checker/créer le chemin
  #
  def folders_upto where
    rep = File.dirname(path)
    if where == :local
      `if [ ! -d "#{rep}" ];then mkdir -p "#{rep}";fi`
    elsif where == :distant
      `ssh #{Fichier::serveur} "if [ ! -d \\"#{rep}\\" ];then mkdir -p \\"#{rep}\\";fi"`
    end
  end
  
  ##
  #
  # Fait une copie de prudence du fichier local
  #
  def copie_local
    return unless File.exist? path
    `if [ ! -d "./xtrash" ];then mkdir -p "./xtrash";fi`
    dest = File.join('.', 'xtrash', basename)
    FileUtils::cp path, dest
  end
  
  ##
  #
  # Nom du fichier
  #
  #
  def basename
    @basename ||= File.basename(path)
  end
  
  ##
  #
  # Le path distant
  #
  def path_distant
    @path_distant ||= begin
      "www/#{path}"
    end
  end
  
end