# encoding: UTF-8
=begin

Module qui gère tout ce qui concerne la connexion de l'user

=end
class User
  
  ##
  #
  # = main =
  #
  # Méthode principale enregistrant des informations dans le
  # pstore-session provisoire de l'user
  #
  # +hdata+ est un {Hash} contenant les données à consigner
  #
  def store hdata
    hdata.merge! updated_at: Time.now.to_i
    PStore::new(pstore_session).transaction { |ps| hdata.each { |k, v| ps[k] = v } }
  end
  
  ##
  #
  # = main =
  #
  # Méthode principale récupérant des informations dans le
  # pstore-session provisoire de l'user
  #
  # @return une valeur (si clé unique en argument) ou un Hash de
  # données.
  #
  # +hkey+ peut être :
  #     * un (symbol | String | Fixnum) => valeur unique retournée
  #     * {Hash} => valeur mise dans le hash, en valeur
  #     * {Array} => liste des clés qu'on renvoie sous forme de Hash
  #       avec les valeurs relevées
  # +default_value+ Valeur par défaut à attribuer seulement si ce n'est
  # pas un Hash. Si c'est un Hash, les valeurs fournies restent les
  # valeurs par défaut.
  #
  def destore hkey, default_value = nil
    case hkey
    when Hash
      PStore::new(pstore_session).transaction do |ps|
        hkey.dup.each do |k, v|
          value = ps.fetch(k, :unfounded_value)
          hkey.merge!( k => value ) unless value == :unfounded_value
        end
      end
      hkey
    when Array
      h = {}
      PStore::new(pstore_session).transaction do |ps|
        hkey.each do |k|
          h.merge! k => ps.fetch(k, default_value)
        end
      end
      h
    else
      PStore::new(pstore_session).transaction do |ps|
        ps.fetch hkey, default_value
      end
    end
  end
  
  ##
  #
  # Enregistre la date de dernière connexion
  #
  # Elle est enregistrée dans les data lecteur, pas dans les
  # data du membre, donc elle est utilisable pour tout user
  # quel qu'il soit.
  #
  def set_last_connexion
    store :last_connexion => Time.now.to_i
  end
  
  ##
  #
  # Enregistre le reader courant comme follower
  # Pour le moment, on ne le sait que lorsqu'il fournit son
  # mail pour émettre un commentaire.
  # On en profite pour vérifier si son IP est enregistrée, et on
  # l'enregistre le cas échéant.
  #
  def store_as_follower
    return unless trustable?
    store( :follower_mail => mail, :user_type => :follower )
    ##
    ## On en profite pour voir si ses données de reader
    ## indiquent qu'il est un follower
    ##
    data_to_set = {}
    d = destore_reader( remote_ip: nil, id: nil, follower: nil )
    ## On ne le fait que si l'IP n'est pas définie, ou que cet IP
    ## enregistrée est bien celle du user courant, dans lequel cas
    ## on est sûr qu'il s'agit de lui.
    if d[:remote_ip].nil? || d[:remote_ip] == remote_ip
      data_to_set.merge!(:remote_ip => remote_ip)   if d[:remote_ip].nil?
      data_to_set.merge!(:id => mail)               if d[:id].nil?
      data_to_set.merge!(:follower => true)         unless d[:follower]
      store_reader data_to_set unless data_to_set.empty?
    end
  end
  
  ##
  #
  # Le path du pstore dans lequel va être enregistré
  # toutes les transactions de l'user courant. Ce pstore
  # porte comme nom le session-id et sera détruit par un cron
  # quotidien qui enregistrera toutes les données dans les
  # pstores généraux correspondant.
  #
  def pstore_session
    if @pstore_session === nil
      npstore = app.session.id || "connexion_test"
      @pstore_session = File.join(app.folder_pstore_session, "#{npstore}.pstore")
      store(created_at: Time.now.to_i)
    end
    @pstore_session
  end
end