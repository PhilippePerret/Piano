# encoding: UTF-8
=begin

Class Fichier pour SSH
----------------------

@usage

    fichier = Fichier::new <path> # avec ou sans './' peu importe

@methodes

    fichier.message_compare_time
        Compare les temps du fichier distant et du fichier local et retourne
        un message approprié.

    fichier.serveur_to_local
        Fait une copie du fichier distant en local
        @Note : on copie de précaution est toujours fait du fichier local.

    fichier.local_to_serveur
        Fait une copie du fichier local vers le site distant

=end
class Fichier
  class << self
    def serveur
      @serveur ||= "piano@ssh.alwaysdata.com"
    end
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
  end
  
  ##
  ## Le path au fichier
  ##
  attr_reader :path
  
  def initialize path
    @path = Fichier::relative_path_of path
  end
  
  ##
  #
  # Pour afficher le fieldset de synchro du fichier
  # C'est un fieldset qui indique l'état de synchronisation et propose un
  # bouton pour updater le fichier online si c'est nécessaire
  #
  # +options+
  #   :show_filename      Si TRUE, affiche le nom du fichier
  #   :message            Si défini, ajoute un message au-dessus du message de 
  #                       synchro
  def fieldset_synchro options = nil
    options ||= {}
    options[:message] = options[:message].to_s.in_div if options.has_key?(:message)
    <<-HTML
<fieldset id="synchronisation_local_distant">
  <legend>Synchronisation local/distant</legend>
  #{options[:message] || ""}
  #{message_synchro options}  
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
  def message_synchro options = nil
    options ||= {}
    tloc = mtime_local
    tdis = mtime_distant
    if tloc == tdis
      "Les deux fichiers local/distant #{options[:show_filename] ? '\"#{path}\" ' : ''}sont synchronisés."
    else
      mess = []
      if tloc > tdis
        # mess << "Le fichier local `#{path}' est plus à jour que le fichier distant".in_div
        if online?
          ## C'est idiot puisque je ne peux pas vérifier quand je suis online…
          mess << "Si vous faites des modifications, des problèmes vont survenir. Il serait plus prudent d'actualiser le fichier distant.".in_div(class: 'warning')
        else
          mess << "Le fichier distant doit être actualisé pour être à jour.".in_div
          mess << "Actualiser le fichier distant".in_a(href: qs_route('su/update_distant', {filepath: path}), class: 'btn medium').in_div(class: 'right')
        end
      else
        if online?
          ## C'est idiot puisque je ne peux pas vérifier quand je suis online…
          mess << "Vous pouvez faire des modifications en toute tranquilité, puis rappatrier le fichier distant en local.".in_div
        else
          mess << "Le fichier distant `#{path}' est plus à jour que le fichier local.".in_div
          mess << "Si vous faites des modifications, des problèmes vont survenir. Il serait plus prudent d'actualiser le fichier local en utilisant le bouton ci-dessous.".in_div(class: 'warning')
          mess << "Actualiser le fichier local".in_a(href: qs_route('su/update_local', {filepath: path}), class: 'btn medium').in_div(class: 'right air')
        end
      end
      mess.join('')
    end
  end
  alias :message_compare_time :message_synchro
  
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
    return res == ""
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
    return res == ""
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
    res = `ssh #{Fichier::serveur} "if [ -f ./www/#{path} ];then echo "1";else echo "0";fi"`
    return res == "1"
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
    if where == :local
      current_relpath = "." # le chemin courant testé
      File.dirname(path).split('/').each do |dossier|
        current_relpath = File.join(current_relpath, dossier)
        Dir.mkdir(current_relpath, 0755) unless File.exist? current_relpath
      end
    elsif where == :distant
      `ssh #{Fichier::serveur} "ruby scripts_ssh/folders_up_to.rb '#{File.dirname(path)}'"`
    end
  end
  
  ##
  #
  # Fait une copie de prudence du fichier local
  #
  def copie_local
    return unless File.exist? path
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