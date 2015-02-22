# encoding: UTF-8
=begin

Classe PPStore
--------------
Gestion des PStore

Classe initiée suite aux problèmes de blocage de PStores sur le Cercle
pianistique.

@usage

  On utilise simplement les deux fonctions :

    ppstore <pstore path>, <{hash data}>
      Pour enregistrer une donnée
      <pstore path> peut être réduit au minimum, sans ".pstore", et sans
      "./" au début. Par exemple "data/pstore/mon_pstore"

    ppdestore <pstore path>, <{hash} or :key>
      Pour récupérer une donnée
      Même note que pour ppstore concernant le path.
      Si le second argument est un hash, on retourne un hash peuplé avec
      les données envoyées, sinon on retourne seulement la valeur de la
      clé :key.

    ppstore_remove <key>
      Détruit (sans pitié) une clé dans le pstore.

  Pour exécuter une opération plus complexe :

    PPStore::new(<path>).transaction do |ps|
      ... code à exécuter dans le pstore ...
    end

  Pour exécuter une action sur toutes les clés

    PPStore::new(<path>).each_root[(except: [...])] do |ps, root|
      ... code à exécuter ...
    end

    Noter que le block retourne toutes les valeurs passées en revue,
    sauf la valeur interne :updated_at.
    

@explication

  Au lieu d'utiliser PStore::new etc. pour les transactions, on fait appel
  à cette classe qui va traiter les transactions de façon plus sûre, en tenant
  compte des threads (ça vient du problème suivant : PStore fonctionne très bien
  au niveau de son verrou sur le même thread, mais n'est pas locké pour des
  threads différents — comme ça peut être le cas sur le net).

  Le système utilisé est de créer un fichier qui indique à tout le monde que le
  pstore est utilisé. C'est un peu lourd, ça peut être plus lent, mais c'est 
  plus sûr.

=end

##
#
# Fonction principale permettant de consigner une donnée dans
# le pstore même s'il est occupé par un autre thread
#
# +sleep_time+ ne sert que pour les tests
#
def ppstore pstore_path, hdata, sleep_time = nil
  PPStore::new( pstore_path ).set hdata, sleep_time
end
def ppdestore pstore_path, key_or_hkey, sleep_time = nil
  PPStore::new( pstore_path ).get key_or_hkey, sleep_time
end
def ppstore_remove pstore_path, key, sleep_time = nil
  PPStore::new( pstore_path ).remove key, sleep_time
end
alias :ppstore_delete :ppstore_remove

class PPStore
  
  attr_reader :path_init
  
  def initialize pstore_path
    @path_init = pstore_path
  end
  
  ##
  #
  # = main =
  #
  # Méthode principale qui enregistre une donnée dans le PStore
  #
  # Pour que le monde sache que ce pstore est occupé, on enregistre
  # un fichier indiquant qu'il est occupé.
  # S'il est occupé par un autre processus, on se met en attente
  #
  # +sleep_time+ sert juste pour les tests
  #
  def set hdata, sleep_time = nil
    sleep 0.1 while busy?
    set_busy
    resultat = true
    pstore.transaction do |ps|
      hdata.each { |k, v| ps[k] = v }
      ps[:updated_at] = Time.now.to_i
      sleep sleep_time unless sleep_time.nil? # pour test
    end
  rescue Exception => e
    debug e
    # puts "e.message : #{e.message}".in_div
    resultat = false
  ensure
    unset_busy
    # puts "Je passe par ensure de set avec resultat = #{resultat.inspect}".in_div
    return resultat # bizarre : sans "return, ça ne retourne pas"
  end
  
  ##
  #
  # Détruit une donnée dans le pstore
  #
  def remove key, sleep_time = nil
    resultat = nil
    sleep 0.1 while busy?
    set_busy
    pstore.transaction do |ps|
      ps.delete key
      resultat = ps.fetch(key, :unfound) == :unfound
      ps[:updated_at] = Time.now.to_i
      sleep sleep_time unless sleep_time.nil?
    end
  rescue Exception => e
    debug e
    resultat = false
  ensure
    unset_busy
    return resultat
  end
  
  ##
  #
  # = main =
  #
  # Méthode principale qui récupère une ou des valeurs dans le pstore
  #
  def get hdata, default_value = nil, sleep_time = nil
    sleep 0.1 while busy?
    pstore.transaction do |ps|
      value = if hdata.class == Hash
        hdata.dup.each do |k, def_value|
          hdata.merge! k => ps.fetch( k, def_value )
        end
        hdata
      else
        ps.fetch hdata, default_value
      end
      sleep sleep_time unless sleep_time.nil? # pour les tests
      value
    end
  end
  
  ##
  #
  # = main =
  #
  # Méthode qui simule le transaction normal
  #
  def transaction sleep_time = nil
    sleep 0.1 while busy?
    set_busy
    resultat = nil
    pstore.transaction do |ps|
      resultat = yield ps
      sleep sleep_time unless sleep_time.nil?
    end
  rescue Exception => e
    debug e
  ensure
    unset_busy
    return resultat # bizarre : sans "return, ça ne retourne pas"
  end
  
  ##
  #
  # = main =
  #
  # Permet une boucle sur chaque clé du pstore, avec un filtre possible
  #
  def each_root filtre = nil, sleep_time = nil
    filtre ||= {except: []}
    filtre.merge! except: [filtre[:except]] unless filtre[:except].class == Array
    filtre[:except] << :updated_at unless filtre[:except].include? :updated_at
    sleep 0.1 while busy?
    set_busy
    resultat = nil
    pstore.transaction do |ps|
      resultat = ps.roots.collect do |root|
        next :_unexcepted_key if filtre[:except].include? root
        yield ps, root
      end.reject{ |e| e == :_unexcepted_key }
      sleep sleep_time unless sleep_time.nil?
    end
  rescue Exception => e
    unset_busy
    raise e
  ensure
    unset_busy
    return resultat # bizarre : sans "return, ça ne retourne pas"
  end
  
  # ---------------------------------------------------------------------
  #
  #     Méthodes d'état et de changement d'état
  #
  # ---------------------------------------------------------------------
  
  ##
  #
  # @return TRUE si le pstore est occupé, même dans un
  # autre thread
  #
  def busy?
    File.exist? path_busy_file
  end
  
  def set_busy
    File.open(path_busy_file, 'wb'){|f| f.write Time.now.to_s }
    pstore.transaction { |ps| ps.commit } # au cas où il aurait été bloqué
  end
  
  def unset_busy
    pstore.transaction { |ps| ps.commit } # au cas où il aurait été bloqué
    File.unlink path_busy_file if File.exist? path_busy_file
  end
  
  # ---------------------------------------------------------------------
  #
  #   L'instance PStore
  #
  # ---------------------------------------------------------------------
  def pstore
    @pstore ||= PStore::new(path)
  end
  
  # ---------------------------------------------------------------------
  #
  #   Paths
  #
  # ---------------------------------------------------------------------

  ##
  #
  # Path du "busy-file"
  #
  def path_busy_file
    @path_busy_file ||= "#{path}-busy"
  end
  
  ##
  #
  # Retourne le bon path au pstore
  #
  def path
    @path ||= begin
      p = path_init.to_s
      p.concat(".pstore") unless p.end_with? ".pstore"
      unless p.start_with? "/"
        p.prepend("./") unless p.start_with? "./"
      end
      File.expand_path p
    end
  end
end